package home

import (
	mm "gno.land/p/pflow000/metamodel"
)

func init() {
	register("bid", func(_ string) string {
		return "```gnomark\n" + bid("g1e8vw6gh284q7ggzqs8ne6r8j9aqhnmvl6rzzmz", "PLACE_BID", 5).ToGnoMark() + "\n```"
	})
	register("ask", func(_ string) string {
		return "```gnomark\n" + ask("g1e8vw6gh284q7ggzqs8ne6r8j9aqhnmvl6rzzmz", "PLACE_ASK", 5).ToGnoMark() + "\n```"
	})
}

// TODO: add denomination support
func bid(toAddress string, action string, multiple int64) *mm.Pflow {
	return &mm.Pflow{
		Places: map[string]mm.Place{
			"$wallet": {Offset: 0, Initial: mm.T(10), Capacity: mm.T(0), X: 20, Y: 100},
			"bid_pool": {Offset: 0, Initial: mm.T(0), Capacity: mm.T(0), X: 270, Y: 100},
		},
		Transitions: map[string]mm.Transition{
			action: {X: 150, Y: 100},
		},
		Arrows: []mm.Arrow{
			{Source: "$wallet", Target: action, Weight: mm.T(multiple)},
			{Source: action, Target: "bid_pool", Weight: mm.T(multiple)},
		},
	}
}

func ask(toAddress string, action string, multiple int64) *mm.Pflow {
	return &mm.Pflow{
		Places: map[string]mm.Place{
			"$wallet": {Offset: 0, Initial: mm.T(10), Capacity: mm.T(0), X: 20, Y: 100},
			"ask_pool": {Offset: 0, Initial: mm.T(0), Capacity: mm.T(0), X: 270, Y: 100},
		},
		Transitions: map[string]mm.Transition{
			action: {X: 150, Y: 100},
		},
		Arrows: []mm.Arrow{
			{Source: "$wallet", Target: action, Weight: mm.T(multiple)},
			{Source: action, Target: "ask_pool", Weight: mm.T(multiple)},
		},
	}
}

// TODO: add min/max price handling, etc.
func Bid(toAddress string, amount int64) {
	m := bid(toAddress, "PLACE_BID", amount)
	// TODO: implement state handling for bids
	_ = m
}

func Ask(toAddress string, amount int64) {
	m := ask(toAddress, "PLACE_ASK", amount)
	// TODO: implement state handling for asks
	_ = m
}