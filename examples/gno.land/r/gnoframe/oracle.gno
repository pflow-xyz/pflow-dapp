package gnoframe

import (
    "std"
)

var (

    idSeq int = 0

	// incoming data being pushed into gno to trigger on-chain reactions
	commands = []map[string]interface{}{
		{
			"id": idSeq,
			"action":   "CommandName",
			"multiple": 1,
		},
	}

	// TODO: coingeko API example
	// https://brand.coingecko.com/resources/attribution-guide

	// outbound queries requesting external data from oracle
	queries = []map[string]interface{}{
		{
			"id": idSeq,
			"fetch": "https://example.com/data.json",
			// "path":     ".data.price", // REVIEW: select a specific path in the JSON response
			"schedule": "Every Block", // other options: "Every Minute", "Every Hour", "Daily"
		},
	}

	// responses to queries are processed by the oracle
	responses = []map[string]interface{}{
		{
			"id": idSeq,
			"name":        "priceResponse",
			"description": "Response structure for price queries.",
			"fields": map[string]string{
				"asset": "The asset for which the price is provided.",
				"price": "The price of the asset.",
			},
			"ttl": 1000, // time-to-live in blocks for on-chain access
		},
	}
)


// this file contains the oracle logic for handling incoming commands and queries
// users may register commands, queries, and responses to interact with the oracle

// RegisterCommand registers a command that the oracle can respond to.
func RegisterCommand(command map[string]interface{}) {
    commands = append(commands, command)
}

// RegisterQuery registers a query that the oracle can respond to.
func RegisterQuery(query map[string]interface{}) {
    queries = append(queries, query)
}

// RegisterResponse registers a response structure for queries.
func RegisterResponse(response map[string]interface{}) {
    responses = append(responses, response)
}

func renderString(value interface{}) string {
    // TODO: support other types if needed
    if str, ok := value.(string); ok {
        return str
    }
    return ""
}

func event(eventType string, data map[string]interface{}) {
    // Emit an event to the oracle with the given type and data
    attributes := make([]string, 0, len(data))
    for key, value := range data {
        attributes = append(attributes, key)
        attributes = append(attributes, renderString(value))
    }
    std.Emit(eventType, attributes...)
}

// Reset clears all registered commands, queries, and responses.
func Reset() {
    idSeq = 0
    commands = []map[string]interface{}{}
    queries = []map[string]interface{}{}
    responses = []map[string]interface{}{}
    event("oracle_reset", map[string]interface{}{
        "id": -1,
        "action": "reset",
    })
}