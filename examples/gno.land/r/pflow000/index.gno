package pflow

import (
    "strings"
)

func Render(path string) string {
    if strings.HasSuffix(path, "model") {
        return RenderExample(path)
    }
	return "## gno.pflow.dev\n ![profile](http://stackdump.com/profile.jpg)" + "\n\n" +
		welcomeMessage
}

// Write a welcome to my realm message
const welcomeMessage = `
👋 Welcome to gno.pflow.dev
You're not just visiting a site — you're entering a living workspace.

Here, models are the code.
Petri nets guide logic.
SVGs carry state.
Markdown becomes interaction.

Built on Gno.land, this is a place for thinkers, builders, and modelers.
Whether you're crafting a contract or simulating a system —
let’s build the future, one transition at a time.


### Explore the Petri-net model
[Explore the test Petri-net model](./pflow000:model) <- See our implementation of the Petri-net model in Gno.land
`