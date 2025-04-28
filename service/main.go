package main

import (
	. "github.com/pflow-xyz/pflow-app/metamodel"
	"github.com/pflow-xyz/pflow-app/metamodel/cid"
	. "github.com/pflow-xyz/pflow-app/metamodel/token"
	"strings"
)

// TODO: support multiple tokens - should it be here? or should users provide

var (
	exampleModel = Model{
		ModelType: "PetriNet",
		Version:   "v0",
		Places: map[string]Place{
			"place0": {Offset: 0, Initial: T(1), Capacity: T(3), X: 130, Y: 207},
			"place1": {Offset: 1, Initial: T(0), Capacity: T(0), X: 395, Y: 299},
		},
		Transitions: map[string]Transition{
			"txn0": {X: 46, Y: 116},
			"txn1": {X: 227, Y: 112},
			"txn2": {X: 43, Y: 307},
			"txn3": {X: 235, Y: 306},
		},
		Arrows: []Arrow{
			{Source: "txn0", Target: "place0", Weight: T(1)},
			{Source: "place0", Target: "txn1", Weight: T(3)},
			{Source: "txn2", Target: "place0", Weight: T(3), Inhibit: true},
			{Source: "place0", Target: "txn3", Weight: T(1), Inhibit: true},
			{Source: "txn3", Target: "place1", Weight: T(1)},
		},
	}

	importedModel, _ = NewModel().FromJson(toJson())
)

func toJson() string {
	var w strings.Builder
	exampleModel.ToJson(&w)
	return w.String()
}

func main() {

	if len(importedModel.Places) != 2 {
		panic("Expected 2 places, got " + string(len(importedModel.Places)))
	}
	if len(importedModel.Transitions) != 4 {
		panic("Expected 4 transitions, got " + string(len(importedModel.Transitions)))
	}
	if len(importedModel.Arrows) != 5 {
		panic("Expected 5 arrows, got " + string(len(importedModel.Arrows)))
	}

	importedCid := cid.NewCid(importedModel).String()
	modelCid := cid.NewCid(exampleModel).String()
	if importedCid != modelCid {
		panic("Expected CIDs to match, got " + importedCid + " != " + modelCid)
	}
}
