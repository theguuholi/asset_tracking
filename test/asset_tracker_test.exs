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

  describe "add_sale" do
    # calculate assets twice when try to sell
    # sell the assets

    test "given an asset that user does not have, when try to sell more than has, throw error message" do
      today = DateTime.utc_now()
      sell_date = today |> DateTime.add(1, :day)

      assert new()
             |> add_purchase("STN", today, 10, 3)
             |> add_sale("STN", sell_date, 13, 6) == {:error, "You don`t enough assets to sell"}
    end

    test "given an asset that user does not have, when try to sell, throw error message" do
      today = DateTime.utc_now()
      sell_date = today |> DateTime.add(1, :day)

      assert new()
             |> add_purchase("STN", today, 10, 3)
             |> add_sale("APP", sell_date, 3, 6) == {:error, "You don`t have this asset to sell"}
    end

    test "given an asset, when sell, return how much was lost" do
      today = DateTime.utc_now()
      sell_date = today |> DateTime.add(1, :day)

      assert new()
             |> add_purchase("STN", today, 10, 3)
             |> add_sale("STN", sell_date, 3, 1) ==
               %AssetTracker{
                 assets: %{
                   "STN" => [
                     %{
                       settle_date: today,
                       quantity: 7,
                       unit_price: 3
                     }
                   ]
                 },
                 sell: %{
                   "STN" => [
                     %{
                       sell_date: sell_date,
                       quantity: 3,
                       unit_price: 1,
                       result: -6
                     }
                   ]
                 }
               }
    end

    test "given an asset, when sell over the quantity, then return the sell" do
      today = DateTime.utc_now()
      sell_date = today |> DateTime.add(1, :day)

      assert new()
             |> add_purchase("STN", today, 10, 3)
             |> add_purchase("STN", sell_date, 10, 4)
             |> add_sale("STN", sell_date, 13, 6) ==
               %AssetTracker{
                 assets: %{
                   "STN" => [
                     %{
                       settle_date: sell_date,
                       quantity: 7,
                       unit_price: 4
                     }
                   ]
                 },
                 sell: %{
                   "STN" => [
                     %{
                       sell_date: sell_date,
                       quantity: 13,
                       unit_price: 6,
                       result: 32.5
                     }
                   ]
                 }
               }
    end

    test "given an asset, when sell, return how much was gained" do
      today = DateTime.utc_now()
      sell_date = today |> DateTime.add(1, :day)

      assert new()
             |> add_purchase("STN", today, 10, 3)
             |> add_sale("STN", sell_date, 3, 6) ==
               %AssetTracker{
                 assets: %{
                   "STN" => [
                     %{
                       settle_date: today,
                       quantity: 7,
                       unit_price: 3
                     }
                   ]
                 },
                 sell: %{
                   "STN" => [
                     %{
                       sell_date: sell_date,
                       quantity: 3,
                       unit_price: 6,
                       result: 9
                     }
                   ]
                 }
               }
    end
  end

  #   unrealized_gain_or_loss/3: Accepts an AssetTracker, an asset symbol (string) and a
  # market_price (integer). Returns the total unrealized capital gain or loss for the asset.

  describe "unrealized_gain_or_loss" do
    test "given an asset when, call the unrealized_gain_or_loss, then return gain or loss" do
      today = DateTime.utc_now()

      assert new()
             |> add_purchase("STN", today, 10, 3)
             |> unrealized_gain_or_loss("STN", 12) == 90
    end

    test "given a list of assets when, call the unrealized_gain_or_loss, then return gain or loss" do
      today = DateTime.utc_now()

      assert new()
             |> add_purchase("STN", today, 10, 3)
             |> add_purchase("STN", today, 20, 30)
             |> unrealized_gain_or_loss("STN", 12) == -270
    end

    test "throw error when try to sell an asset that user does not have " do
      today = DateTime.utc_now()

      assert new()
             |> add_purchase("STN", today, 10, 3)
             |> add_purchase("STN", today, 20, 30)
             |> unrealized_gain_or_loss("pumpkin", 12) == {:error, "You don`t have this asset"}
    end
  end
end
