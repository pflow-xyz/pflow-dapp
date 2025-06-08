package home

import (
	mm "gno.land/p/pflow000/metamodel"
)

func init() {
	register("transfer", func(_ string) string {
		return "```gnomark\n" + transfer().ToGnoMark() + "\n```"
	})
}

// TODO: upgrade to support multiple token colors
func transfer(toAddress string, action, multiple int64) *mm.Pflow {
    _ = toAddress // unused in this example
    _ = action // unused in this example
    _ = multiple // unused in this example

    // TODO: template petri-net from input parameters

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
			{Source: "txn0", Target: "place0", Weight: mm.T(4)},
			{Source: "place0", Target: "txn1", Weight: mm.T(3)},
			{Source: "txn2", Target: "place0", Weight: mm.T(3), Inhibit: true},
			{Source: "place0", Target: "txn3", Weight: mm.T(1), Inhibit: true},
		},
	}
}
