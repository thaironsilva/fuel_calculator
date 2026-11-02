defmodule FuelCalculator.Planet do
  @moduledoc """
  Single source of truth for the planets supported by the calculator.

      iex> FuelCalculator.Planet.parse("Moon")
      {:ok, :moon}

      iex> FuelCalculator.Planet.parse("Pluto")
      :error

      iex> FuelCalculator.Planet.label(:earth)
      "Earth"
  """

  @type t :: :earth | :moon | :mars

  @planets [:earth, :moon, :mars]
  @gravity %{earth: 9.807, moon: 1.62, mars: 3.711}
  @labels %{earth: "Earth", moon: "Moon", mars: "Mars"}

  @spec all() :: [t()]
  def all, do: @planets

  @spec gravity(t()) :: float()
  def gravity(planet) when planet in @planets, do: Map.fetch!(@gravity, planet)
  def gravity(planet), do: raise(ArgumentError, "unknown planet: #{inspect(planet)}")

  @spec label(t()) :: String.t()
  def label(planet), do: Map.fetch!(@labels, planet)

  @spec parse(String.t()) :: {:ok, t()} | :error
  def parse(value) when is_binary(value) do
    value = value |> String.trim() |> String.downcase()

    Enum.find_value(@planets, :error, fn planet ->
      if String.downcase(Map.fetch!(@labels, planet)) == value, do: {:ok, planet}
    end)
  end

  def parse(_), do: :error

  @spec valid?(term()) :: boolean()
  def valid?(planet), do: planet in @planets
end
