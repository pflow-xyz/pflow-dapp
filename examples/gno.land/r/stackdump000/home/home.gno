package home

import (
	mm "gno.land/p/pflow000/metamodel"
)

func init() {
    register("exampleModelV1", func (_ string) string {
        return "```gnomark\n" + newSource + "\n```"
    })
}

// v1 source code example
var newSource = `
{
  "gnoMark": "petrinet",
  "petrinet": {
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
}`

// TODO: upgrade to
// exampleModel returns a simple Petri net model.
func exampleModel() *mm.Pflow {
	return &mm.Pflow{
		Places: map[string]mm.Place{
			"place0": {Offset: 0, Initial: mm.T(1), Capacity: mm.T(3), X: 130, Y: 207},
		},
		Transitions: map[string]mm.Transition{
			"txn0": {X: 46, Y: 116},
			"txn1": {X: 227, Y: 112},
			"txn2": {X: 43, Y: 307},
			"txn3": {X: 235, Y: 306},
		},
		Arrows: []mm.Arrow{
			{Source: "txn0", Target: "place0", Weight: mm.T(1)},
			{Source: "place0", Target: "txn1", Weight: mm.T(3)},
			{Source: "txn2", Target: "place0", Weight: mm.T(3), Inhibit: true},
			{Source: "place0", Target: "txn3", Weight: mm.T(1), Inhibit: true},
		},
	}
}