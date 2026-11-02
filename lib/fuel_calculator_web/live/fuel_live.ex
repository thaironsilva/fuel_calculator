defmodule FuelCalculatorWeb.FuelLive do
  use FuelCalculatorWeb, :live_view

  alias FuelCalculator.{FuelCalculator, Planet}

  @default_steps [
    {:launch, :earth},
    {:land, :moon},
    {:launch, :moon},
    {:land, :earth}
  ]

  @default_mass 28_801
  @actions [:launch, :land]

  @planet_styles %{
    earth: %{
      icon: "hero-globe-alt",
      dot: "bg-sky-400",
      chip: "border-sky-400/30 bg-sky-400/10 text-sky-200",
      quick:
        "border-sky-400/20 bg-sky-400/5 text-sky-200 hover:border-sky-400/40 hover:bg-sky-400/15"
    },
    moon: %{
      icon: "hero-moon",
      dot: "bg-slate-300",
      chip: "border-slate-300/30 bg-slate-300/10 text-slate-100",
      quick:
        "border-slate-300/20 bg-slate-300/5 text-slate-200 hover:border-slate-300/40 hover:bg-slate-300/15"
    },
    mars: %{
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
    mass_input = to_string(@default_mass)

    socket =
      socket
      |> assign(:planets, Planet.all())
      |> assign(:planet_styles, @planet_styles)
      |> assign(:action_styles, @action_styles)
      |> assign(:actions, @actions)
      |> assign(:action, :launch)
      |> assign(:steps, @default_steps)
      |> assign(:mass_input, mass_input)
      |> assign(:mass_error, nil)
      |> assign(:step_error, nil)
      |> assign(:step_form, step_form(""))
      |> assign(:mass_form, mass_form(mass_input))
      |> recalculate()

    {:ok, socket}
  end

  @impl true
  def handle_event("set_action", %{"action" => value}, socket) when is_binary(value) do
    case parse_action(value) do
      nil -> {:noreply, socket}
      action -> {:noreply, assign(socket, :action, action)}
    end
  end

  def handle_event("set_action", _params, socket), do: {:noreply, socket}

  def handle_event("submit_step", %{"step" => %{"planet" => value}}, socket)
      when is_binary(value) do
    case Planet.parse(value) do
      {:ok, planet} ->
        {:noreply, add_step(socket, planet)}

      :error ->
        step_error = if String.trim(value) == "", do: nil, else: "Choose Earth, Moon, or Mars."

        {:noreply,
         socket
         |> assign(:step_form, step_form(value))
         |> assign(:step_error, step_error)}
    end
  end

  def handle_event("submit_step", _params, socket), do: {:noreply, socket}

  def handle_event("select_planet", %{"planet" => value}, socket) when is_binary(value) do
    case Planet.parse(value) do
      {:ok, planet} -> {:noreply, add_step(socket, planet)}
      :error -> {:noreply, socket}
    end
  end

  def handle_event("select_planet", _params, socket), do: {:noreply, socket}

  def handle_event("add_step", %{"planet" => value}, socket) when is_binary(value) do
    case Planet.parse(value) do
      {:ok, planet} -> {:noreply, add_step(socket, planet)}
      :error -> {:noreply, socket}
    end
  end

  def handle_event("add_step", _params, socket), do: {:noreply, socket}

  def handle_event("remove_step", %{"index" => index}, socket) do
    with {index, ""} <- Integer.parse(index),
         true <- index >= 0 and index < length(socket.assigns.steps) do
      socket =
        socket
        |> assign(:steps, List.delete_at(socket.assigns.steps, index))
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

  defp add_step(socket, planet) do
    step = {socket.assigns.action, planet}

    socket
    |> assign(:steps, socket.assigns.steps ++ [step])
    |> assign(:step_form, step_form(""))
    |> assign(:step_error, nil)
    |> recalculate()
    |> push_event("clear_step_input", %{})
  end

  defp recalculate(socket) do
    steps = socket.assigns.steps
    mass = parse_mass(socket.assigns.mass_input)

    fuel =
      if steps != [] and is_number(mass) do
        FuelCalculator.calculate_fuel(steps, mass)
      end

    assign(socket,
      trajectory: trajectory(steps),
      mass: mass,
      fuel: fuel
    )
  end

  defp trajectory(steps) do
    last_index = length(steps) - 1

    steps
    |> Enum.with_index()
    |> Enum.map(fn {{action, planet}, index} ->
      %{action: action, planet: planet, index: index, last?: index == last_index}
    end)
  end

  defp parse_action("launch"), do: :launch
  defp parse_action("land"), do: :land
  defp parse_action(_), do: nil

  defp parse_mass(value) when is_binary(value) do
    case Float.parse(String.trim(value)) do
      {mass, ""} when mass > 0 -> mass
      _ -> nil
    end
  end

  defp parse_mass(_), do: nil

  defp mass_error(value) when is_binary(value) do
    cond do
      String.trim(value) == "" -> nil
      is_number(parse_mass(value)) -> nil
      true -> "Use a positive number."
    end
  end

  defp mass_error(_), do: "Use a positive number."

  defp step_form(value), do: to_form(%{"planet" => value}, as: :step)
  defp mass_form(value), do: to_form(%{"mass" => value}, as: :ship)

  defp format_fuel(nil), do: "—"
  defp format_fuel(fuel), do: format_number(fuel)

  defp format_number(nil), do: "—"

  defp format_number(number) when is_integer(number) do
    number |> Integer.to_string() |> group_digits()
  end

  defp format_number(number) when is_float(number) do
    [integer, decimal] =
      number
      |> Float.to_string()
      |> String.split(".", parts: 2)

    grouped = group_digits(integer)

    if decimal == "0", do: grouped, else: grouped <> "." <> decimal
  end

  defp group_digits(value) do
    value
    |> String.reverse()
    |> String.replace(~r/(\d{3})(?=\d)/, "\\1,")
    |> String.reverse()
  end

  defp result_hint(nil, steps, mass_input) do
    cond do
      steps == [] -> "Add at least one step to see the trajectory and fuel."
      String.trim(mass_input) == "" -> "Enter the ship mass to calculate fuel."
      true -> "Enter a positive number for the ship mass."
    end
  end

  defp result_hint(_fuel, _steps, _mass_input) do
    "Includes launch, landing, and fuel-carrying costs."
  end
end
