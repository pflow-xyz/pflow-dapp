package home

import (
	"gno.land/p/demo/avl"
)

var (
	registry         = avl.NewTree()
	realmAllowPrefix = []string{}
	displayPaths     = []string{
		// "exampleModelV1", // REVIEW: can we add model to the page 2x w/o issue??
		"transfer",
	}
)

func init() {
	allowPatchesFromSubRealms()
}

