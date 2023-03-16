defmodule AssetTrackerTest do
  use ExUnit.Case
  import AssetTracker

  test "new/0" do
    assert new() == %AssetTracker{}
  end

  test "add_purchase/5" do
    today = Date.utc_today()

    assert add_purchase(new(), "STN", today, 10, 3) == %AssetTracker{
             symbol: "STN",
             settle_date: today,
             quantity: 10,
             unit_price: 3
           }
  end
end
