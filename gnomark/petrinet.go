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

var petriNetTemplate = `
    <style type="text/css">
        @import url("{CDN}pflow.css");
    </style>
    <svg id="svgCanvas" width="100%" height="100%"  xmlns="http://www.w3.org/2000/svg">
        <foreignObject height="100%" width="100%" x="0" y="0">
            <object id="svgObject" type="image/svg+xml" data="{CDN}model.svg"></object>
        </foreignObject>
        <g id="toolbar">
            <g id="status" transform="translate(5, 607)" >
                <rect x="0" y="0" width="140" height="20" fill="#fff" rx="5" ry="5"/>
                <text x="10" y="15">Status: Ready</text>
            </g>
            <g id="playBtn" transform="translate(148, 604)" >
                <circle cx="12" cy="11" r="20" fill="transparent" stroke="transparent" stroke-width="2" />
                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2m0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8m-2.5-3.5 7-4.5-7-4.5z"></path>
            </g>
        </g>
        <g id="history" transform="translate(5, 605)" ></g>
        <foreignObject height="50%" width="98%" x="0" y="635">
            <textarea id="source">{SOURCE}</textarea>
        </foreignObject>
    </svg>
    <script src="{CDN}pflow.js"></script>
`
