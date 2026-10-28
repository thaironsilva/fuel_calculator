defmodule FuelCalculatorWeb.FuelLiveTest do
  use FuelCalculatorWeb.ConnCase

  import Phoenix.LiveViewTest

  test "renders the default mission", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#fuel-result-value", "51,898")
    assert has_element?(view, "#route-chip-0", "Earth")
    assert has_element?(view, "#route-chip-1", "Moon")
    assert has_element?(view, "#route-chip-2", "Earth")

    assert has_element?(view, "#trajectory-step-0", "Launch")
    assert has_element?(view, "#trajectory-step-0", "Earth")
    assert has_element?(view, "#trajectory-step-1", "Land")
    assert has_element?(view, "#trajectory-step-1", "Moon")
    assert has_element?(view, "#trajectory-step-2", "Launch")
    assert has_element?(view, "#trajectory-step-2", "Moon")
    assert has_element?(view, "#trajectory-step-3", "Land")
    assert has_element?(view, "#trajectory-step-3", "Earth")

    assert has_element?(view, "#quick-add-earth")
    assert has_element?(view, "#quick-add-moon")
    assert has_element?(view, "#quick-add-mars")
  end

  test "adds a stop when the form is submitted", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("#add-stop-form")
    |> render_submit(%{"stop" => %{"planet" => "Mars"}})

    assert has_element?(view, "#route-chip-3", "Mars")
    assert has_element?(view, "#stop-planet[value='']")
    assert has_element?(view, "#trajectory-step-5", "Land")
    assert has_element?(view, "#trajectory-step-5", "Mars")
  end

  test "adds a stop when a planet is selected from the datalist", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view |> render_hook("select_planet", %{"planet" => "Mars"})

    assert has_element?(view, "#route-chip-3", "Mars")
    assert has_element?(view, "#stop-planet[value='']")
    assert has_element?(view, "#trajectory-step-5", "Mars")
  end

  test "submitting an empty stop is a no-op", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("#add-stop-form")
    |> render_submit(%{"stop" => %{"planet" => ""}})

    assert has_element?(view, "#route-chip-2", "Earth")
    refute has_element?(view, "#route-chip-3")
  end

  test "quick-adds a stop", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#quick-add-mars") |> render_click()

    assert has_element?(view, "#route-chip-3", "Mars")
    assert has_element?(view, "#trajectory-step-5", "Mars")
  end

  test "removes a stop and recalculates", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#remove-stop-1") |> render_click()

    refute has_element?(view, "#route-chip-2")
    assert has_element?(view, "#route-chip-1", "Earth")
    assert has_element?(view, "#trajectory-step-1", "Land")
    refute has_element?(view, "#trajectory-step-2")
  end

  test "validates the ship mass", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("#mass-form")
    |> render_change(%{"ship" => %{"mass" => "0"}})

    assert has_element?(view, "#mass-error", "whole number greater than zero")
    assert has_element?(view, "#fuel-result-value", "—")

    view
    |> element("#mass-form")
    |> render_change(%{"ship" => %{"mass" => "28801"}})

    refute has_element?(view, "#mass-error")
    assert has_element?(view, "#fuel-result-value", "51,898")
  end

  test "ignores an unknown planet", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("#add-stop-form")
    |> render_submit(%{"stop" => %{"planet" => "Pluto"}})

    assert has_element?(view, "#route-error", "Choose Earth, Moon, or Mars.")
    assert has_element?(view, "#route-chip-2", "Earth")
    refute has_element?(view, "#route-chip-3")
  end

  test "shows an empty state when the route is empty", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#remove-stop-2") |> render_click()
    view |> element("#remove-stop-1") |> render_click()
    view |> element("#remove-stop-0") |> render_click()

    assert has_element?(view, "#stop-planet")
    assert has_element?(view, "#trajectory-empty")
    assert has_element?(view, "#fuel-result-value", "—")
  end
end
