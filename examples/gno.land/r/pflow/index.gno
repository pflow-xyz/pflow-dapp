package pflow

var modelJson = `{
  "gnoMark": "petrinet",
  "modelType": "PetriNet",
  "version": "v1",
  "tokens": ["black"],
  "places": {
    "place0": { "offset": 0, "initial": [1], "capacity": [3], "x": 130, "y": 207 }
  },
  "transitions": {
    "txn0": { "x": 46, "y": 116 },
    "txn1": { "x": 227, "y": 112 },
    "txn2": { "x": 43, "y": 307 },
    "txn3": { "x": 235, "y": 306 }
  },
  "arcs": [
    { "source": "txn0", "target": "place0", "weight": [1] },
    { "source": "place0", "target": "txn1", "weight": [3] },
    { "source": "txn2", "target": "place0", "weight": [3], "inhibit": true },
    { "source": "place0", "target": "txn3", "weight": [1], "inhibit": true }
  ]
}
`

var newSource = "<gno-mark>\n\n" + modelJson + "\n" + "</gno-mark>\n\n"

func Render(path string) string {
	return "![profile](http://stackdump.com/profile.jpg)" + "\n\n" +
		welcomeMessage + "\n\n" +
		"## Model\n\n" +
		"```mermaid\n" +
		diagram + "\n" +
		"```\n\n"

}

// This is a simple sequence diagram for a coffee ordering process
const diagram = `
sequenceDiagram
    participant Customer
    participant Barista

    Customer->>+Barista: I'd like to order a coffee
    Barista-->>-Customer: Your order is being prepared
    Barista->>+CoffeeMachine: Start brewing coffee
    CoffeeMachine-->>-Barista: Coffee is ready
    Barista->>+Customer: Here is your coffee
    Customer-->>-Barista: Thank you! (makes payment)
`

// Write a welcome to my realm message
const welcomeMessage = `
👋 Welcome to pflow.xyz
You're not just visiting a site — you're entering a living workspace.

Here, models are the code.
Petri nets guide logic.
SVGs carry state.
Markdown becomes interaction.

Built on Gno.land, this is a place for thinkers, builders, and modelers.
Whether you're crafting a contract or simulating a system —
let’s build the future, one transition at a time.
`
