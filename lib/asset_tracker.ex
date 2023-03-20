defmodule AssetTracker do
  defstruct assets: %{}, sell: %{}

  def new do
    %__MODULE__{}
  end

  def add_purchase(asset_tracker, symbol, settle_date, quantity, unit_price) do
    asset_info = %{
      settle_date: settle_date,
      quantity: quantity,
      unit_price: unit_price
    }

    %{
      asset_tracker
      | assets:
          Map.update(asset_tracker.assets, symbol, [asset_info], fn assets_info ->
            assets_info ++ [asset_info]
          end)
    }
  end

  def add_sale(asset_tracker, symbol, sell_date, quantity, unit_price) do
    asset_tracker.assets
    |> update_assets(symbol, quantity)
    |> sell_assets(asset_tracker, symbol, sell_date, quantity, unit_price)
  end

  defp sell_assets({:not_enough_quantity, _}, _, _, _, _, _),
    do: {:error, "You don`t enough assets to sell"}

  defp sell_assets({nil, _}, _, _, _, _, _), do: {:error, "You don`t have this asset to sell"}

  defp sell_assets(
         {old_unit_price, updated_asset},
         asset_tracker,
         symbol,
         sell_date,
         quantity,
         unit_price
       ) do
    asset_tracker = %{asset_tracker | assets: updated_asset}
    result = calculate_result(old_unit_price, quantity, unit_price)

    sell_result = %{
      quantity: quantity,
      result: result,
      sell_date: sell_date,
      unit_price: unit_price
    }

    update_sell =
      Map.put(asset_tracker.sell, symbol, [
        sell_result
      ])

    %{asset_tracker | sell: update_sell}
  end

  defp calculate_result(unit_price_bought, quantity_sold, unit_price_sold) do
    unit_price_bought = Enum.sum(unit_price_bought) / length(unit_price_bought)
    quantity_sold * (unit_price_sold - unit_price_bought)
  end

  defp update_assets(assets, symbol, quantity_sold) do
    Map.get_and_update(assets, symbol, &check_assets_status_and_sell(&1, quantity_sold))
  end

  defp check_assets_status_and_sell(nil, _), do: :pop

  defp check_assets_status_and_sell(assets, quantity_sold) do
    total_quantity = Enum.reduce(assets, 0, &(&1.quantity + &2))

    if quantity_sold > total_quantity do
      {:not_enough_quantity, assets}
    else
      {unit_prices, new_assets_list, _} =
        Enum.reduce(assets, {[], [], quantity_sold}, fn asset,
                                                        {unit_prices, new_assets_list,
                                                         quantity_missing_to_sell} ->
          cond do
            quantity_missing_to_sell == 0 ->
              {unit_prices, new_assets_list ++ [asset], quantity_missing_to_sell}

            asset.quantity == quantity_missing_to_sell ->
              {unit_prices ++ [asset.unit_price], new_assets_list, quantity_sold}

            asset.quantity > quantity_missing_to_sell ->
              new_quantity_sold = quantity_missing_to_sell - asset.quantity
              new_value = [Map.put(asset, :quantity, asset.quantity - quantity_missing_to_sell)]

              {unit_prices ++ [asset.unit_price], new_assets_list ++ new_value, new_quantity_sold}

            quantity_missing_to_sell > asset.quantity ->
              new_quantity_sold = quantity_missing_to_sell - asset.quantity

              {unit_prices ++ [asset.unit_price], new_assets_list, new_quantity_sold}

            quantity_missing_to_sell < asset.quantity ->
              new_quantity_sold = quantity_missing_to_sell - asset.quantity
              new_value = [Map.put(asset, :quantity, asset.quantity - quantity_missing_to_sell)]

              {unit_prices ++ [asset.unit_price], new_assets_list ++ new_value, new_quantity_sold}
          end
        end)

      {unit_prices, new_assets_list}
    end
  end

  def unrealized_gain_or_loss(asset_tracker, symbol, market_price) do
    asset_tracker.assets
    |> Map.get(symbol, {:error, "You don`t have this asset"})
    |> check_unrealized_gain_or_loss(market_price)
  end

  defp check_unrealized_gain_or_loss({:error, _} = err, _), do: err

  defp check_unrealized_gain_or_loss(assets, market_price) do
    assets
    |> Enum.map(fn asset ->
      value = market_price - asset.unit_price
      value * asset.quantity
    end)
    |> Enum.sum()
  end
end
