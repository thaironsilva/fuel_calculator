defmodule FuelCalculator.FuelCalculator do
  @moduledoc """
  Module to calculate the fuel necessary for spacecraft travel
  Launch: mass * gravity * 0.042 - 33 (rounded down)
  Landing: mass * gravity * 0.033 - 42 (rounded down)
  """

  @spec calculate_fuel(list(:atom), integer()) :: integer()
  def calculate_fuel(route, ship_mass) do
    {total_fuel, _total_ship_mass} =
      route
      |> Enum.reverse()
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.reduce({0, ship_mass}, fn [to, from], {acc_fuel, acc_ship_mass} ->
        landing_fuel = calculate_fuel(:landing, to, acc_ship_mass)
        launch_fuel = calculate_fuel(:launch, from, acc_ship_mass + landing_fuel)
        {acc_fuel + landing_fuel + launch_fuel, landing_fuel + launch_fuel + acc_ship_mass}
      end)

    total_fuel
  end

  @spec calculate_fuel(:landing | :launch, :earth | :mars | :moon, integer()) :: integer()
  def calculate_fuel(ship_action, planet, ship_mass) do
    fuel_calc_func = fuel_calc_func(ship_action)
    fuel = fuel_calc_func.(planet, ship_mass)

    if fuel <= 0, do: 0, else: fuel + calculate_fuel(ship_action, planet, fuel)
  end

  defp fuel_calc_func(:launch),
    do: fn planet, mass -> floor(mass * gravity(planet) * 0.042 - 33) end

  defp fuel_calc_func(:landing),
    do: fn planet, mass -> floor(mass * gravity(planet) * 0.033 - 42) end

  defp gravity(:earth), do: 9.807
  defp gravity(:moon), do: 1.62
  defp gravity(:mars), do: 3.711
end
