defmodule FuelCalculator.FuelCalculatorTest do
  use ExUnit.Case, async: true

  alias FuelCalculator.FuelCalculator

  describe "calculate_fuel/3" do
    test "Apollo 11 land on earth" do
      assert 13447 == FuelCalculator.calculate_fuel(:landing, :earth, 28801)
    end
  end

  describe "calculate_fuel/2" do
    test "Apollo 11 Mission" do
      assert 51898 == FuelCalculator.calculate_fuel([:earth, :moon, :earth], 28801)
    end

    test "Mars Mission" do
      assert 33388 == FuelCalculator.calculate_fuel([:earth, :mars, :earth], 14606)
    end

    test "Passenger Ship Mission" do
      assert 212_161 == FuelCalculator.calculate_fuel([:earth, :moon, :mars, :earth], 75432)
    end
  end
end
