defmodule AssetTrackerTest do
  use ExUnit.Case
  import AssetTracker

  test "new/0" do
    assert new() == %AssetTracker{assets: %{}}
  end

  describe "add purchase" do
    test "given a new asset to add to wallet, when add return the assets list" do
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

    test "given an asset that user bought twice, when add the asset, then return using a list when they bought the asset" do
      today = DateTime.utc_now()
      tomorrow = today |> DateTime.add(1, :day)

      assert new()
             |> add_purchase("STN", today, 10, 3)
             |> add_purchase("STN", tomorrow, 15, 6) ==
               %AssetTracker{
                 assets: %{
                   "STN" => [
                     %{
                       settle_date: today,
                       quantity: 10,
                       unit_price: 3
                     },
                     %{
                       settle_date: tomorrow,
                       quantity: 15,
                       unit_price: 6
                     }
                   ]
                 }
               }
    end

    test "given an user that has assets, when bought a new one, then return the new asset" do
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
end
