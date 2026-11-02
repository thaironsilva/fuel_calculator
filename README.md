# Fuel Calculator

<img width="1308" height="858" alt="image" src="https://github.com/user-attachments/assets/4f5b4c2f-abfa-4f77-b745-b20a54b52d40" />

A small Phoenix LiveView app for planning a space flight and calculating the fuel required. Pick launch and landing steps, set the ship mass, and the trajectory and total fuel update as you go.

## Why it's intentionally small

This is a focused demo, not a production platform. The fuel calculation is pure and stateless, so there is no database. There is no authentication because there are no user accounts or private data. There is no CI/CD pipeline because the goal was to keep the project easy to run and review locally; tests, formatting, and Dialyzer run through Mix.

For a production version, I'd add a CI workflow, deployment/observability, authentication and maybe user/saved missions.

## Run locally

```bash
mix setup
mix phx.server
```

Visit [localhost:4000](http://localhost:4000).

## Tests and checks

```bash
mix test          # unit, doctest, and LiveView tests
mix dialyzer
mix precommit     # format, compile with warnings as errors, and test
```

## Docker

```bash
docker compose up --build
```

Visit [localhost:4000](http://localhost:4000). Stop with `docker compose down`.
