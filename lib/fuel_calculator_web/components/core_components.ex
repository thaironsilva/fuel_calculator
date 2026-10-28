defmodule FuelCalculatorWeb.CoreComponents do
  @moduledoc """
  Core UI components.
  """

  use Phoenix.Component

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  ## Examples

      <.icon name="hero-x-mark" />
      <.icon name="hero-rocket-launch" class="size-4" />
  """
  attr :name, :string, required: true
  attr :class, :any, default: "size-4"

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end
end
