package home

import (
	"gno.land/p/demo/avl"
)

var (
	registry         = avl.NewTree()
	realmAllowPrefix = []string{}
	displayPaths     = []string{
		//"exampleModelV1",
		"transfer",
	}
)

func init() {
	allowPatchesFromSubRealms()
}

