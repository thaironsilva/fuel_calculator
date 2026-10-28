defmodule FuelCalculatorWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use FuelCalculatorWeb, :html

  # Embed all files in layouts/* within this module.
  embed_templates "layouts/*"

  @doc """
  Renders the application layout.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="relative min-h-screen overflow-hidden bg-slate-950 text-slate-100 antialiased">
      <div class="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_top,_rgba(99,102,241,0.2),_transparent_55%)]">
      </div>
      <div class="starfield pointer-events-none absolute inset-0 opacity-70"></div>
      <main class="relative mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 lg:px-8 lg:py-16">
        {render_slot(@inner_block)}
      </main>
    </div>
    """
  end
end
