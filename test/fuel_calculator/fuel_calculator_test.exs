defmodule FuelCalculator.FuelCalculatorTest do
  use ExUnit.Case, async: true

  alias FuelCalculator.FuelCalculator, as: Fuel

  doctest FuelCalculator.FuelCalculator
  doctest FuelCalculator.Planet

  describe "calculate_fuel/3" do
    test "launching from earth" do
      assert 19_772 == Fuel.calculate_fuel(:launch, :earth, 28_801)
    end

    test "landing on earth" do
      assert 13_447 == Fuel.calculate_fuel(:land, :earth, 28_801)
    end

    test "landing on the moon" do
      assert 1_535 == Fuel.calculate_fuel(:land, :moon, 28_801)
    end

    test "launching from the moon" do
      assert 2_024 == Fuel.calculate_fuel(:launch, :moon, 28_801)
    end

    test "returns zero when the formula is not positive" do
      assert 0 == Fuel.calculate_fuel(:launch, :earth, 1)
      assert 0 == Fuel.calculate_fuel(:launch, :earth, 0)
      assert 0 == Fuel.calculate_fuel(:launch, :earth, -5)
    end

    test "accepts fractional masses" do
      assert 13_448 == Fuel.calculate_fuel(:land, :earth, 28_801.5)
      assert 19_773 == Fuel.calculate_fuel(:launch, :earth, 28_801.5)
    end
  end

  describe "calculate_fuel/2" do
    test "Apollo 11 Mission" do
      steps = [
        {:launch, :earth},
        {:land, :moon},
        {:launch, :moon},
        {:land, :earth}
      ]

      assert 51_898 == Fuel.calculate_fuel(steps, 28_801)
    end

    test "Mars Mission" do
      steps = [
        {:launch, :earth},
        {:land, :mars},
        {:launch, :mars},
        {:land, :earth}
      ]

      assert 33_388 == Fuel.calculate_fuel(steps, 14_606)
    end

    test "Passenger Ship Mission" do
      steps = [
        {:launch, :earth},
        {:land, :moon},
        {:launch, :moon},
        {:land, :mars},
        {:launch, :mars},
        {:land, :earth}
      ]

      assert 212_161 == Fuel.calculate_fuel(steps, 75_432)
    end

    test "supports single-action missions" do
      assert 19_772 == Fuel.calculate_fuel([{:launch, :earth}], 28_801)
      assert 13_447 == Fuel.calculate_fuel([{:land, :earth}], 28_801)
    end

    test "supports consecutive launches and landings" do
      assert 53_364 ==
               Fuel.calculate_fuel([{:launch, :earth}, {:launch, :earth}], 28_801)

      assert 3_156 ==
               Fuel.calculate_fuel([{:land, :moon}, {:land, :moon}], 28_801)
    end

    test "empty missions need no fuel" do
      assert 0 == Fuel.calculate_fuel([], 28_801)
    end

    test "accepts fractional masses" do
      steps = [
        {:launch, :earth},
        {:land, :moon},
        {:launch, :moon},
        {:land, :earth}
      ]

      assert 51_900 == Fuel.calculate_fuel(steps, 28_801.5)
    end

    test "returns zero for zero or negative mass" do
      assert 0 == Fuel.calculate_fuel([{:launch, :earth}], 0)
      assert 0 == Fuel.calculate_fuel([{:launch, :earth}], -5)
    end

    test "raises for unknown planets" do
      assert_raise ArgumentError, ~r/unknown planet/, fn ->
        Fuel.calculate_fuel([{:launch, :pluto}], 100)
      end
    end

    test "raises for unknown actions" do
      assert_raise ArgumentError, ~r/invalid flight step/, fn ->
        Fuel.calculate_fuel([{:orbit, :earth}], 100)
      end
    end
  end
end
