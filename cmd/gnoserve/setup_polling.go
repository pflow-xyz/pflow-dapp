package main

import (
	"context"
	"fmt"
	"github.com/gnolang/gno/tm2/pkg/bft/rpc/client"
	. "github.com/pflow-xyz/pflow-app/metamodel"
	"github.com/pflow-xyz/pflow-app/metamodel/cid"
	. "github.com/pflow-xyz/pflow-app/metamodel/token"
	"log/slog"
	"strings"
	"time"
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

func tick(cli *client.RPCClient, logger *slog.Logger) {
	qpath := "vm/qrender"
	data := []byte("gno.land/r/gnoframe:frame")

	// add a defer to recover from any panics during the tick
	defer func() {
		if r := recover(); r != nil {
			logger.Error("panic during tick", "error", r)
		}
	}()

	logger.Info("Ticking...")

	// read the '/r/gnoframe realm display func
	logger.Info("Polling for events...")

	res, err := cli.ABCIQuery(qpath, data)
	if err != nil {
		logger.Error("error querying events", "error", err)
		return
	}
	if len(res.Response.Data) == 0 {
		logger.Info("No events found in response")
		return
	}
	logger.Info(fmt.Sprintf("Events found: %s", res.Response.Data))
}

func setupPolling(ctx context.Context, logger *slog.Logger, remoteAddr string) {
	httpClient, err := client.NewHTTPClient(remoteAddr)
	_ = httpClient // TODO: use this client to poll events
	if err != nil {
		logger.Error("unable to create HTTP client", "error", err)
		return
	}
	ticker := time.NewTicker(5 * time.Second) // match block time of gno chain

	go func() {
		for {
			select {
			case <-ticker.C:
				tick(httpClient, logger)
			case <-ctx.Done():
				ticker.Stop()
				return
			}
		}
	}()
}

// TODO: actually remove
func exampleTest() {
	importedCid := cid.NewCid(importedModel).String()
	modelCid := cid.NewCid(exampleModel).String()
	if importedCid != modelCid {
		panic("Expected CIDs to match, got " + importedCid + " != " + modelCid)
	}
}
