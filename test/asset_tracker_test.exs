defmodule AssetTrackerTest do
  use ExUnit.Case
  import AssetTracker

  test "new/0" do
    assert new() == %AssetTracker{assets: %{}}
  end

  test "add_purchase/5" do
    today = DateTime.utc_now()

    assert add_purchase(new(), "STN", today, 10, 3) == %AssetTracker{
             assets: %{
               "STN" => [
                 %{
                   settle_date: today,
                   quantity: 10,
                   unit_price: 3
                 }
               ]
             }
           }
  end

  test "add_purchase/5 add twice same assets" do
    today = DateTime.utc_now()

    assert new()
           |> add_purchase("STN", today, 10, 3)
           |> add_purchase("STN", today, 15, 6) ==
             %AssetTracker{
               assets: %{
                 "STN" => [
                   %{
                     settle_date: today,
                     quantity: 10,
                     unit_price: 3
                   },
                   %{
                     settle_date: today,
                     quantity: 15,
                     unit_price: 6
                   }
                 ]
               }
             }
  end

  test "add_purchase/5 with different symbol" do
    today = DateTime.utc_now()

    assert new()
           |> add_purchase("STN", today, 10, 3)
           |> add_purchase("Apl", today, 13, 4) ==
             %AssetTracker{
               assets: %{
                 "STN" => [
                   %{
                     settle_date: today,
                     quantity: 10,
                     unit_price: 3
                   }
                 ],
                 "Apl" => [
                   %{
                     settle_date: today,
                     quantity: 13,
                     unit_price: 4
                   }
                 ]
               }
             }
  end
end
