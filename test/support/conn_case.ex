defmodule FuelCalculatorWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require a connection.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint FuelCalculatorWeb.Endpoint

      use FuelCalculatorWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import FuelCalculatorWeb.ConnCase
    end
  end

  setup do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
