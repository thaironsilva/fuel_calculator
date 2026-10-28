// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"

const Hooks = {
  PlanetInput: {
    mounted() {
      this.handleEvent("clear_stop_input", () => {
        this.el.value = ""
      })

      const planets = (this.el.dataset.planets || "")
        .split(",")
        .map((planet) => planet.trim().toLowerCase())
        .filter(Boolean)

      const validPlanet = () => planets.includes(this.el.value.trim().toLowerCase())

      this.el.addEventListener("change", () => {
        if (document.activeElement === this.el && validPlanet()) {
          this.skipNextSubmit = true
          this.pushEvent("select_planet", {planet: this.el.value})
          setTimeout(() => {
            this.skipNextSubmit = false
          }, 0)
        }
      })

      this.el.form.addEventListener(
        "submit",
        (event) => {
          if (this.skipNextSubmit) {
            event.preventDefault()
            event.stopImmediatePropagation()
            this.skipNextSubmit = false
          }
        },
        true,
      )
    },
  },
}

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks,
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket
