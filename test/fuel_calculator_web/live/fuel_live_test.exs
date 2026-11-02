defmodule FuelCalculatorWeb.FuelLiveTest do
  use FuelCalculatorWeb.ConnCase

  import Phoenix.LiveViewTest

  test "renders the default mission", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#fuel-result-value", "51,898")

    assert has_element?(view, "#step-chip-0", "Launch")
    assert has_element?(view, "#step-chip-0", "Earth")
    assert has_element?(view, "#step-chip-1", "Land")
    assert has_element?(view, "#step-chip-1", "Moon")
    assert has_element?(view, "#step-chip-2", "Launch")
    assert has_element?(view, "#step-chip-2", "Moon")
    assert has_element?(view, "#step-chip-3", "Land")
    assert has_element?(view, "#step-chip-3", "Earth")

    assert has_element?(view, "#trajectory-step-0", "Launch")
    assert has_element?(view, "#trajectory-step-0", "Earth")
    assert has_element?(view, "#trajectory-step-1", "Land")
    assert has_element?(view, "#trajectory-step-1", "Moon")
    assert has_element?(view, "#trajectory-step-2", "Launch")
    assert has_element?(view, "#trajectory-step-2", "Moon")
    assert has_element?(view, "#trajectory-step-3", "Land")
    assert has_element?(view, "#trajectory-step-3", "Earth")

    assert has_element?(view, "#action-launch")
    assert has_element?(view, "#action-land")
    assert has_element?(view, "#quick-add-earth")
    assert has_element?(view, "#quick-add-moon")
    assert has_element?(view, "#quick-add-mars")
  end

  test "adds a step when the form is submitted", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("#add-step-form")
    |> render_submit(%{"step" => %{"planet" => "Mars"}})

    assert has_element?(view, "#step-chip-4", "Launch")
    assert has_element?(view, "#step-chip-4", "Mars")
    assert has_element?(view, "#step-planet[value='']")
    assert has_element?(view, "#trajectory-step-4", "Launch")
    assert has_element?(view, "#trajectory-step-4", "Mars")
  end

  test "adds a step when a planet is selected from the datalist", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view |> render_hook("select_planet", %{"planet" => "Mars"})

    assert has_element?(view, "#step-chip-4", "Launch")
    assert has_element?(view, "#step-chip-4", "Mars")
    assert has_element?(view, "#step-planet[value='']")
  end

  test "adds a landing step after selecting the land action", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#action-land") |> render_click()
    view |> render_hook("select_planet", %{"planet" => "Mars"})

    assert has_element?(view, "#step-chip-4", "Land")
    assert has_element?(view, "#step-chip-4", "Mars")
    assert has_element?(view, "#trajectory-step-4", "Land")
    assert has_element?(view, "#trajectory-step-4", "Mars")
  end

  test "quick-add uses the selected action", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#action-land") |> render_click()
    view |> element("#quick-add-mars") |> render_click()

    assert has_element?(view, "#step-chip-4", "Land")
    assert has_element?(view, "#step-chip-4", "Mars")
  end

  test "submitting an empty step is a no-op", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("#add-step-form")
    |> render_submit(%{"step" => %{"planet" => ""}})

    assert has_element?(view, "#step-chip-3", "Earth")
    refute has_element?(view, "#step-chip-4")
  end

  test "removes a step and recalculates", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#remove-step-1") |> render_click()

    refute has_element?(view, "#step-chip-3")
    assert has_element?(view, "#step-chip-1", "Launch")
    assert has_element?(view, "#step-chip-1", "Moon")
    assert has_element?(view, "#trajectory-step-2", "Land")
    assert has_element?(view, "#trajectory-step-2", "Earth")
  end

  test "supports a single-step mission", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#remove-step-3") |> render_click()
    view |> element("#remove-step-2") |> render_click()
    view |> element("#remove-step-1") |> render_click()

    assert has_element?(view, "#step-chip-0", "Launch")
    assert has_element?(view, "#step-chip-0", "Earth")
    assert has_element?(view, "#fuel-result-value", "19,772")
    refute has_element?(view, "#trajectory-empty")
  end

  test "validates the ship mass", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("#mass-form")
    |> render_change(%{"ship" => %{"mass" => "0"}})

    assert has_element?(view, "#mass-error", "Use a positive number.")
    assert has_element?(view, "#fuel-result-value", "—")

    view
    |> element("#mass-form")
    |> render_change(%{"ship" => %{"mass" => "28801"}})

    refute has_element?(view, "#mass-error")
    assert has_element?(view, "#fuel-result-value", "51,898")
  end

  test "accepts a fractional ship mass", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("#mass-form")
    |> render_change(%{"ship" => %{"mass" => "28801.5"}})

    refute has_element?(view, "#mass-error")
    assert has_element?(view, "#fuel-result-value", "51,900")
    assert has_element?(view, "#fuel-result-meta", "28,801.5")
  end

  test "ignores an unknown planet", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("#add-step-form")
    |> render_submit(%{"step" => %{"planet" => "Pluto"}})

    assert has_element?(view, "#step-error", "Choose Earth, Moon, or Mars.")
    assert has_element?(view, "#step-chip-3", "Earth")
    refute has_element?(view, "#step-chip-4")
  end

  test "shows an empty state when the route is empty", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#remove-step-3") |> render_click()
    view |> element("#remove-step-2") |> render_click()
    view |> element("#remove-step-1") |> render_click()
    view |> element("#remove-step-0") |> render_click()

    assert has_element?(view, "#step-planet")
    assert has_element?(view, "#trajectory-empty")
    assert has_element?(view, "#fuel-result-value", "—")
  end
end
