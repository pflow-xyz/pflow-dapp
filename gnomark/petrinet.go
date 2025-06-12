package gnomark

import (
	"encoding/json"
	"strings"
)

var (
	// serve files from the CDN
	// petriNetWebHost = &WebHost{
	// 	Base: "https://cdn.jsdelivr.net/gh/pflow-xyz/pflow-dapp@",
	// 	Tag:  "main",
	// 	Path: "/static/",
	// }

	// serve files from the local filesystem
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

var petriNetTemplate = `
    <petri-net>
		{SOURCE}
    </petri-net>
`
