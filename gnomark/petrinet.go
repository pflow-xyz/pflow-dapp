package gnomark

import (
	"encoding/json"
	"strings"
)

var (
	// petriNetWebHost = &WebHost{
	// 	Base: "https://cdn.jsdelivr.net/gh/pflow-xyz/pflow-app@",
	// 	Tag:  "0.2.1",
	// 	Path: "/static/",
	// }

	// serve files from the same webserver
	petriNetWebHost = &WebHost{
		Base: "",
		Tag:  "",
		Path: "/static/",
	}
)

func petriNetHtml(key, value string, s string) (out string) {
	out = strings.ReplaceAll(petriNetTemplate, key, value)
	return strings.ReplaceAll(out, "{SOURCE}", getPetriNetJson(s))
}

func getPetriNetJson(source string) string {
	var data map[string]interface{}

	err := json.Unmarshal([]byte(source), &data)
	if err != nil {
		return `{ "error": "invalid json" }`
	}

	// get the "petrinet" key
	petriNetData, ok := data["petrinet"].(map[string]interface{})
	if !ok {
		return `{ "error": "invalid json: missing key: 'petrinet'" }`
	}
	// convert the map to a json string
	petriNetJson, err := json.Marshal(petriNetData)
	if err != nil {
		return `{ "error": "invalid json: unable to marshal 'petrinet' key" }`
	}
	// return the json string
	return string(petriNetJson)
}

func printSource(s map[string]interface{}) string {
	// FIXME: print nicely formatted json
	return ""
}

func petriNetRender(source string) string {
	return petriNetHtml("{CDN}", petriNetWebHost.Cdn(), source)
}

// FIXME replace hardcoded values with values from the json
var petriNetTemplate = `
    <petri-net source='{
        "modelType": "PetriNet",
        "version": "v1",
        "tokens": ["black"],
        "places": {
            "place0": { "offset": 0, "initial": [3], "capacity": [3], "x": 130, "y": 207 }
        },
        "transitions": {
            "txn0": { "x": 46, "y": 116 },
            "txn1": { "x": 227, "y": 112 },
            "txn2": { "x": 43, "y": 307 },
            "txn3": { "x": 235, "y": 306 }
        },
        "arcs": [
            { "source": "txn0", "target": "place0", "weight": [1] },
            { "source": "place0", "target": "txn1", "weight": [3] },
            { "source": "txn2", "target": "place0", "weight": [3], "inhibit": true },
            { "source": "place0", "target": "txn3", "weight": [1], "inhibit": true }
        ]
    }'></petri-net>
    <script src="{CDN}petri-net.js"></script>
`
