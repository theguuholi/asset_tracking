defmodule AssetTracker do
  defstruct symbol: nil,
            settle_date: Date.utc_today(),
            quantity: nil,
            unit_price: nil

  def new do
    %__MODULE__{}
  end

  def add_purchase(asset_tracker, symbol, settle_date, quantity, unit_price) do
    %{
      asset_tracker
      | symbol: symbol,
        settle_date: settle_date,
        quantity: quantity,
        unit_price: unit_price
    }
  end
end
