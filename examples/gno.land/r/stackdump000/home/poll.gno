package home

import (
	mm "gno.land/p/pflow000/metamodel"
)

func init() {
	register("poll", func(_ string) string {
		return "```gnomark\n" + poll("$wallet", "VOTE", "choice1", "choice2", "choice3").ToGnoMark() + "\n```"
	})
}

func poll(fromAddress string, baseAction string, choices ...string) *mm.Pflow {
	places := map[string]mm.Place{
		"voteOnce": {Offset: 0, Initial: mm.T(1), Capacity: mm.T(1), X: 20, Y: 100},
	}

	arrows := []mm.Arrow{}
	transitions := map[string]mm.Transition{}

	// Dynamically add places, transitions, and arrows for each choice
	for i, choice := range choices {
		placeX := 300 // Keep all choices at the same X coordinate
		placeY := 100 + (i * 70) // Adjust Y position for vertical spacing
		action := baseAction + "_" + choice // Create a unique action for each choice

		places[choice] = mm.Place{Offset: 0, Initial: mm.T(0), Capacity: mm.T(0), X: placeX, Y: placeY}
		transitions[action] = mm.Transition{X: 120, Y: placeY} // Position action at the same Y as the choice

		arrows = append(arrows, mm.Arrow{Source: "voteOnce", Target: action, Weight: mm.T(1)})
		arrows = append(arrows, mm.Arrow{Source: action, Target: choice, Weight: mm.T(1)})
	}

	return &mm.Pflow{
		Places:      places,
		Transitions: transitions,
		Arrows:      arrows,
	}
}

func Poll(fromAddress string, amount int64, choices ...string) {
	m := poll(fromAddress, "VOTE", choices...)
	// TODO: implement state handling for polls
	_ = m
}

// show the poll using SVG button choices inside a GnoMark code block
func PollGnoMark(fromAddress string, amount int64, choices ...string) string {
    p := poll(fromAddress, "VOTE", choices...)
    return "```gnomark\n" + p.ToGnoMark() + "\n```"
}