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
    quantity_sold * (unit_price_sold - unit_price_bought)
  end

  defp update_assets(assets, symbol, quantity_sold) do
    Map.get_and_update(assets, symbol, &check_assets_status_and_sell(&1, quantity_sold))
  end

  defp check_assets_status_and_sell(nil, _), do: :pop

  defp check_assets_status_and_sell(assets, quantity_sold) do
    asset = hd(assets)

    if quantity_sold > asset.quantity do
      {:not_enough_quantity, assets}
    else
      new_quantity_sold = asset.quantity - quantity_sold
      new_value = [Map.put(asset, :quantity, new_quantity_sold)]
      {asset.unit_price, new_value}
    end
  end
end
