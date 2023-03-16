defmodule AssetTracker do
  # defstruct symbol: nil,
  #           settle_date: Date.utc_today(),
  #           quantity: nil,
  #           unit_price: nil
  defstruct assets: %{}

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

  def add_sale(asset_tracker, _symbol, sell_date, quantity, unit_price) do
    # symbol, seems not to make sense
    # I did not understand the advantage of using gain and loss
    gain = quantity * (unit_price - asset_tracker.unit_price)

    quantity_updated = asset_tracker.quantity - quantity

    asset_tracker = %{
      asset_tracker
      | settle_date: sell_date,
        quantity: quantity_updated,
        unit_price: unit_price
    }

    {asset_tracker, %{gain: gain, loss: 0}}
  end
end
