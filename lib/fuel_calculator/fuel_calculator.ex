defmodule FuelCalculator.FuelCalculator do
  @moduledoc """
  Calculates the fuel necessary for spacecraft travel.

  Launch: mass * gravity * 0.042 - 33 (rounded down)

  Landing: mass * gravity * 0.033 - 42 (rounded down)

  A mission is an ordered list of flight steps. Each step pairs an action with
  the planet where it happens, so launches and landings can be composed freely,
  including single-action missions.

      iex> FuelCalculator.FuelCalculator.calculate_fuel([{:launch, :earth}], 28_801)
      19_772

      iex> FuelCalculator.FuelCalculator.calculate_fuel([{:land, :earth}], 28_801)
      13_447

      iex> FuelCalculator.FuelCalculator.calculate_fuel([], 28_801)
      0

      iex> steps = [
      ...>   {:launch, :earth},
      ...>   {:land, :moon},
      ...>   {:launch, :moon},
      ...>   {:land, :earth}
      ...> ]
      iex> FuelCalculator.FuelCalculator.calculate_fuel(steps, 28_801)
      51_898
  """

  alias FuelCalculator.Planet

  @type action :: :launch | :land
  @type step :: {action(), Planet.t()}
  @type mass :: number()
  @type fuel :: non_neg_integer()

  @actions [:launch, :land]

  @doc """
  Calculates the total fuel for an ordered list of flight steps.
  """
  @spec calculate_fuel([step()], mass()) :: fuel()
  def calculate_fuel(steps, ship_mass) when is_list(steps) and is_number(ship_mass) do
    Enum.each(steps, &validate_step!/1)

    steps
    |> Enum.reverse()
    |> Enum.reduce({0, ship_mass}, fn {action, planet}, {total, mass} ->
      step_fuel = calculate_fuel(action, planet, mass)
      {total + step_fuel, mass + step_fuel}
    end)
    |> elem(0)
  end

  @doc """
  Calculates the fuel for a single launch or landing.
  """
  @spec calculate_fuel(action(), Planet.t(), mass()) :: fuel()
  def calculate_fuel(action, planet, ship_mass)
      when action in @actions and is_number(ship_mass) do
    fuel = fuel_for(action, planet, ship_mass)

    if fuel <= 0, do: 0, else: fuel + calculate_fuel(action, planet, fuel)
  end

  defp fuel_for(:launch, planet, mass), do: floor(mass * Planet.gravity(planet) * 0.042 - 33)
  defp fuel_for(:land, planet, mass), do: floor(mass * Planet.gravity(planet) * 0.033 - 42)

  defp validate_step!({action, planet}) when action in @actions do
    unless Planet.valid?(planet) do
      raise ArgumentError, "unknown planet: #{inspect(planet)}"
    end
  end

  defp validate_step!(step), do: raise(ArgumentError, "invalid flight step: #{inspect(step)}")
end
