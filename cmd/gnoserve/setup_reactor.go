package main

import (
	"context"
	"github.com/gnolang/gno/tm2/pkg/bft/rpc/client"
	"github.com/pflow-xyz/pflow-dapp/reactor"
	"log/slog"
	"time"
)

// TODO: this should be a config option or environment variable
var ReactorEnabled = false

func setupReactor(ctx context.Context, logger *slog.Logger, remoteAddr string) {
	httpClient, err := client.NewHTTPClient(remoteAddr)
	_ = httpClient // TODO: use this client to poll events
	if err != nil {
		logger.Error("unable to create HTTP client", "error", err)
		return
	}
	ticker := time.NewTicker(5 * time.Second) // match block time of gno chain

	if !ReactorEnabled {
		logger.Info("Reactor is disabled")
		return
	}

	go func() {
		for {
			select {
			case <-ticker.C:
				reactor.Tick(httpClient, logger)
			case <-ctx.Done():
				ticker.Stop()
				return
			}
		}
	}()
}
