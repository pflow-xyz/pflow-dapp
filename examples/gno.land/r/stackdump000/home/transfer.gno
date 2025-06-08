package home

import (
	mm "gno.land/p/pflow000/metamodel"
)

func init() {
	register("transfer", func(_ string) string {
		return "```gnomark\n" + transfer("g1e8vw6gh284q7ggzqs8ne6r8j9aqhnmvl6rzzmz", "PAY2ADDR", 3).ToGnoMark() + "\n```"
	})
}

func transfer(toAddress string, action string, multiple int64) *mm.Pflow {
	return &mm.Pflow{
		Places: map[string]mm.Place{
			"$wallet": {Offset: 0, Initial: mm.T(9), Capacity: mm.T(0), X: 20, Y: 100},
			toAddress: {Offset: 0, Initial: mm.T(0), Capacity: mm.T(0), X: 270, Y: 100},
		},
		Transitions: map[string]mm.Transition{
			action: {X: 150, Y: 100},
		},
		Arrows: []mm.Arrow{
			{Source: "$wallet", Target: action, Weight: mm.T(multiple)},
			{Source: action, Target: toAddress, Weight: mm.T(multiple)},
		},
	}
}
