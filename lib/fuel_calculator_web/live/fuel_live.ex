defmodule FuelCalculatorWeb.FuelLive do
  use FuelCalculatorWeb, :live_view

  alias FuelCalculator.FuelCalculator

  @default_route [:earth, :moon, :earth]
  @default_mass 28_801
  @planets [:earth, :moon, :mars]

  @planet_styles %{
    earth: %{
      label: "Earth",
      icon: "hero-globe-alt",
      dot: "bg-sky-400",
      chip: "border-sky-400/30 bg-sky-400/10 text-sky-200",
      quick:
        "border-sky-400/20 bg-sky-400/5 text-sky-200 hover:border-sky-400/40 hover:bg-sky-400/15"
    },
    moon: %{
      label: "Moon",
      icon: "hero-moon",
      dot: "bg-slate-300",
      chip: "border-slate-300/30 bg-slate-300/10 text-slate-100",
      quick:
        "border-slate-300/20 bg-slate-300/5 text-slate-200 hover:border-slate-300/40 hover:bg-slate-300/15"
    },
    mars: %{
      label: "Mars",
      icon: "hero-fire",
      dot: "bg-orange-400",
      chip: "border-orange-400/30 bg-orange-400/10 text-orange-200",
      quick:
        "border-orange-400/20 bg-orange-400/5 text-orange-200 hover:border-orange-400/40 hover:bg-orange-400/15"
    }
  }

  @action_styles %{
    launch: %{
      label: "Launch",
      icon: "hero-rocket-launch",
      badge: "bg-indigo-500/15 text-indigo-300 ring-indigo-400/30",
      description: "Ignition and ascent from the surface."
    },
    land: %{
      label: "Land",
      icon: "hero-arrow-down-circle",
      badge: "bg-emerald-500/15 text-emerald-300 ring-emerald-400/30",
      description: "Controlled descent and touchdown."
    }
  }

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:planets, @planets)
      |> assign(:planet_styles, @planet_styles)
      |> assign(:action_styles, @action_styles)
      |> assign(:route, @default_route)
      |> assign(:mass_input, Integer.to_string(@default_mass))
      |> assign(:mass_error, nil)
      |> assign(:route_error, nil)
      |> assign(:stop_form, stop_form(""))
      |> assign(:mass_form, mass_form(Integer.to_string(@default_mass)))
      |> recalculate()

    {:ok, socket}
  end

  @impl true
  def handle_event("submit_stop", %{"stop" => %{"planet" => value}}, socket) do
    case parse_planet(value) do
      nil ->
        route_error = if String.trim(value) == "", do: nil, else: "Choose Earth, Moon, or Mars."

        {:noreply,
         socket
         |> assign(:stop_form, stop_form(value))
         |> assign(:route_error, route_error)}

      planet ->
        {:noreply, add_planet(socket, planet)}
    end
  end

  def handle_event("select_planet", %{"planet" => value}, socket) do
    case parse_planet(value) do
      nil -> {:noreply, socket}
      planet -> {:noreply, add_planet(socket, planet)}
    end
  end

  def handle_event("add_planet", %{"planet" => value}, socket) do
    case parse_planet(value) do
      nil -> {:noreply, socket}
      planet -> {:noreply, add_planet(socket, planet)}
    end
  end

  def handle_event("remove_stop", %{"index" => index}, socket) do
    with {index, ""} <- Integer.parse(index),
         true <- index >= 0 and index < length(socket.assigns.route) do
      socket =
        socket
        |> assign(:route, List.delete_at(socket.assigns.route, index))
        |> recalculate()

      {:noreply, socket}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("set_mass", %{"ship" => %{"mass" => value}}, socket) do
    socket =
      socket
      |> assign(:mass_input, value)
      |> assign(:mass_form, mass_form(value))
      |> assign(:mass_error, mass_error(value))
      |> recalculate()

    {:noreply, socket}
  end

  defp add_planet(socket, planet) do
    socket
    |> assign(:route, socket.assigns.route ++ [planet])
    |> assign(:stop_form, stop_form(""))
    |> assign(:route_error, nil)
    |> recalculate()
    |> push_event("clear_stop_input", %{})
  end

  defp recalculate(socket) do
    route = socket.assigns.route
    mass = parse_mass(socket.assigns.mass_input)

    fuel =
      if length(route) >= 2 and is_integer(mass) do
        FuelCalculator.calculate_fuel(route, mass)
      end

    assign(socket,
      trajectory: trajectory(route),
      mass: mass,
      fuel: fuel
    )
  end

  defp trajectory(route) do
    steps =
      route
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.flat_map(fn [from, to] -> [{:launch, from}, {:land, to}] end)

    last_index = length(steps) - 1

    steps
    |> Enum.with_index()
    |> Enum.map(fn {{action, planet}, index} ->
      %{action: action, planet: planet, index: index, last?: index == last_index}
    end)
  end

  defp parse_planet(value) when is_binary(value) do
    case value |> String.trim() |> String.downcase() do
      "earth" -> :earth
      "moon" -> :moon
      "mars" -> :mars
      _ -> nil
    end
  end

  defp parse_planet(_), do: nil

  defp parse_mass(value) do
    case Integer.parse(String.trim(value)) do
      {mass, ""} when mass > 0 -> mass
      _ -> nil
    end
  end

  defp mass_error(value) do
    cond do
      String.trim(value) == "" -> nil
      is_integer(parse_mass(value)) -> nil
      true -> "Use a whole number greater than zero."
    end
  end

  defp stop_form(value), do: to_form(%{"planet" => value}, as: :stop)
  defp mass_form(value), do: to_form(%{"mass" => value}, as: :ship)

  defp format_fuel(nil), do: "—"
  defp format_fuel(fuel), do: format_number(fuel)

  defp format_number(nil), do: "—"

  defp format_number(number) when is_integer(number) do
    number
    |> Integer.to_string()
    |> String.reverse()
    |> String.replace(~r/(\d{3})(?=\d)/, "\\1,")
    |> String.reverse()
  end

  defp result_hint(nil, route, mass_input) do
    cond do
      length(route) < 2 -> "Add at least two stops to see the trajectory and fuel."
      String.trim(mass_input) == "" -> "Enter the ship mass to calculate fuel."
      true -> "Enter a whole number greater than zero for the ship mass."
    end
  end

  defp result_hint(_fuel, _route, _mass_input) do
    "Includes launch, landing, and fuel-carrying costs."
  end
end
