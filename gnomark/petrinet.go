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
    <svg xmlns="http://www.w3.org/2000/svg" width="400" height="400" viewBox="0 0 400 400" >
        <style type="text/css">
            .place { fill: #ffffff; stroke: #000000; stroke-width: 1.5; }
            .transition { fill: #ffffff; stroke: #000000; stroke-width: 1.5; cursor: pointer; user-select: text;}
            .transition.enabled { fill: #62fa75 }
            .transition.inhibited { fill: #fab5b0; stroke: #000000; stroke-width: 1.5; cursor: pointer; user-select: text;}
            .arc { stroke: #000000; stroke-width: 1; }
            .label { font-size: small; font-family: sans-serif; fill: #000000; user-select: none; }
            .token { fill: #000000; stroke: gray; stroke-width: 0.5; }
            .tokenSmall { font-size: small; user-select: none; font-weight: bold; }
        </style>
        <defs>
            <marker id="markerArrow1" markerWidth="22.5" markerHeight="12" refX="9" refY="6" orient="auto">
                <path d="M3,1.5 L3,12 L10.5,6 L3,1.5"/>
            </marker>
            <marker id="markerInhibit1" markerWidth="30" markerHeight="16" refX="10" refY="8" orient="auto">
                <circle cx="8" cy="9" r="4"/>
            </marker>
        </defs>
<script>
let petriNet = {};
let sequence = 0;

function arcEndpoints(x1, y1, x2, y2) {
    const length = Math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2);
    const shorten = 22;
    const ratio = shorten / length;

    const newX1 = x1 + (x2 - x1) * ratio;
    const newY1 = y1 + (y2 - y1) * ratio;
    const newX2 = x2 - (x2 - x1) * ratio;
    const newY2 = y2 - (y2 - y1) * ratio;

    const midX = (newX1 + newX2) / 2;
    const midY = (newY1 + newY2) / 2;

    return {
        x1: newX1, y1: newY1, x2: newX2, y2: newY2, midX, midY
    };
}

function createElements() {
    const svg = document.querySelector("svg");
    const fragment = document.createDocumentFragment();

    // Create arcs
    petriNet.arcs.forEach(arc => {
        // REVIEW: places and transitions must not re-use IDs, ensure unique IDs for arcs
        const source = petriNet.places[arc.source] || petriNet.transitions[arc.source];
        const target = petriNet.places[arc.target] || petriNet.transitions[arc.target];
        if (!source || !target) {
            console.error("Source or target not found for arc: ", arc);
            return;
        }
        const { x1, y1, x2, y2, midX, midY } = arcEndpoints(source.x, source.y, target.x, target.y);

        let path = document.createElementNS("http://www.w3.org/2000/svg", "line");
        path.setAttribute("class", "arc");
        path.setAttribute("x1", x1);
        path.setAttribute("y1", y1);
        path.setAttribute("x2", x2);
        path.setAttribute("y2", y2);
        path.setAttribute("class", "arc");
        if (arc.inhibit && arc.inhibit === true) {
            path.setAttribute("marker-end", "url(#markerInhibit1)");
        } else {
            path.setAttribute("marker-end", "url(#markerArrow1)");
        }
        fragment.appendChild(path);

        const angle = Math.atan2(y2 - y1, x2 - x1);
        let x
        let y

        if (x2 < x1) {
            x = midX + 7 * Math.cos(angle + Math.PI / 2);
            y = midY + 7 * Math.sin(angle + Math.PI / 2);
        } else {
            x = midX - 7 * Math.cos(angle + Math.PI / 2);
            y = midY - 7 * Math.sin(angle + Math.PI / 2);
        }

        let color = "black"; // colorize token weights
        for (let i = 0; i < arc.weight.length; i++) {
            if (arc.weight[i] > 0) {
                color = petriNet.tokens[i];
                break;
            }
        }

        let text = document.createElementNS("http://www.w3.org/2000/svg", "text");
        text.setAttribute("x", x);
        text.setAttribute("y", y);
        text.setAttribute("class", "label "+color);
        text.textContent = arc.weight[0];
        fragment.appendChild(text);
    });

    // Create places
    Object.entries(petriNet.places).forEach(([id, place]) => {
        let circle = document.createElementNS("http://www.w3.org/2000/svg", "circle");
        circle.setAttribute("id", id);
        circle.setAttribute("class", "place");
        circle.setAttribute("cx", place.x);
        circle.setAttribute("cy", place.y);
        circle.setAttribute("r", "16");
        fragment.appendChild(circle);

        let text = document.createElementNS("http://www.w3.org/2000/svg", "text");
        text.setAttribute("x", place.x - 18);
        text.setAttribute("y", place.y - 20);
        text.setAttribute("class", "label");
        text.textContent = id;
        fragment.appendChild(text);
    });

    // Create transitions
    Object.entries(petriNet.transitions).forEach(([id, transition]) => {
        let rect = document.createElementNS("http://www.w3.org/2000/svg", "rect");
        rect.setAttribute("id", id);
        let enabled = canFire(id);
        let inhibited = isInhibited(id);
        console.log({id, enabled, inhibited })
        if (inhibited) {
            rect.setAttribute("class", "transition inhibited");
        } else if (enabled) {
            rect.setAttribute("class", "transition enabled");
        } else {
            rect.setAttribute("class", "transition");
        }
        rect.setAttribute("x", transition.x - 15);
        rect.setAttribute("y", transition.y - 15);
        rect.setAttribute("rx", "5");
        rect.setAttribute("width", "30");
        rect.setAttribute("height", "30");
        fragment.appendChild(rect);

        let text = document.createElementNS("http://www.w3.org/2000/svg", "text");
        text.setAttribute("x", transition.x - 15);
        text.setAttribute("y", transition.y - 20);

        text.setAttribute("class", "label");
        text.textContent = id;
        fragment.appendChild(text);

        rect.addEventListener('click', () => fireTransition(id));
    });

    document.querySelectorAll(".place, .transition, .arc, .label").forEach(e => e.remove());
    svg.appendChild(fragment);
}

function canFire(id) {
    let sourceArcs = petriNet.arcs.filter(arc => arc.target === id && !arc.inhibit);
    let targetArcs = petriNet.arcs.filter(arc => arc.source === id && !arc.inhibit);
    let enabled = true;
    sourceArcs.forEach(arc => {
        let place = petriNet.places[arc.source];
        for (let i = 0; i < place.tokens.length; i++) {
            if (arc.weight[i] > place.tokens[i]) {
                enabled = false;
                return;
            }
        }
    });
    targetArcs.forEach(arc => {
        let place = petriNet.places[arc.target];
        if (!place.tokens) {
            place.tokens = []; // KLUDGE: why is this needed?
        }
        for (let i = 0; i < place.tokens.length; i++) {
            console.log({arc, place, out: arc.weight[i] + place.tokens[i], cap: place.capacity[i]
            })
            if (arc.weight[i] + place.tokens[i] > place.capacity[i]) {
                enabled = false;
                return;
            }
        }
    });
    return enabled;
}

function isInhibited(id) {
    let sourceArcs = petriNet.arcs.filter(arc => (arc.target === id && arc.inhibit === true));
    let targetArcs = petriNet.arcs.filter(arc => (arc.source === id && arc.inhibit === true));
    let inhibited = false;
    sourceArcs.forEach(arc => {
        let place = petriNet.places[arc.source];
        for (let i = 0; i <= place.tokens.length; i++) {
            if (place.tokens[i] >= arc.weight[i]) {
                inhibited = true;
                return
            }
        }
    });
    targetArcs.forEach(arc => {
        let place = petriNet.places[arc.target];
        for (let i = 0; i < place.tokens.length; i++) {
            if (place.tokens[i] < arc.weight[i]) {
                inhibited =  true;
            }
        }
    });
    return inhibited;
}

function fireTransition(id, dryRun = false) {
    const exists = petriNet.transitions && petriNet.transitions[id]
    const inhibited = isInhibited(id)
    const enabled = canFire(id)
    if (!exists) {
        console.error("Transition not found: ", id);
        return;
    } else if (inhibited) {
        console.warn("Transition is inhibited: ", id);
        return;
    } else if (!enabled) {
        console.warn("Transition is not enabled: ", id);
        return;
    } else if (!dryRun) {
        let sourceArcs = petriNet.arcs.filter(arc => arc.target === id && !arc.inhibit);
        let targetArcs = petriNet.arcs.filter(arc => arc.source === id && !arc.inhibit);
        sourceArcs.forEach(arc => {
            let place = petriNet.places[arc.source];
            for (let i = 0; i < place.tokens.length; i++) {
                place.tokens[i] -= arc.weight[i];
            }
        });
        targetArcs.forEach(arc => {
            let place = petriNet.places[arc.target];
            for (let i = 0; i < place.tokens.length; i++) {
                place.tokens[i] += arc.weight[i];
            }
        });
        updateTokens();
        window.parent.postMessage({
            type: 'transitionFired',
            sequence: ++sequence,
            transitionId: id,
            petriNet: petriNet
        }, '*');
    }
    return true;
}

function updateTokens() {
    document.querySelectorAll(".token, .tokenSmall").forEach(e =>e.remove());
    const fragment = document.createDocumentFragment();
    Object.entries(petriNet.places).forEach(([, place]) => {
        // Create tokens
        for (let i = 0; i < place.tokens.length; i++) {
            if (place.tokens[i] === 0) continue;
            if (place.tokens[i] === 1) {
                let token = document.createElementNS("http://www.w3.org/2000/svg", "circle");
                token.setAttribute("cx", place.x);
                token.setAttribute("cy", place.y);
                token.setAttribute("r", "3");
                token.setAttribute("class", "token " + petriNet.tokens[i]);
                fragment.appendChild(token);
            } else if (place.tokens[i] > 1) {
                let text = document.createElementNS("http://www.w3.org/2000/svg", "text");
                text.setAttribute("x", place.x - 3);
                text.setAttribute("y", place.y + 4);
                text.setAttribute("class", "tokenSmall " + petriNet.tokens[i]);
                text.textContent = place.tokens[i];
                fragment.appendChild(text);
            }
        }
    });

    // update transition colors
    Object.entries(petriNet.transitions).forEach(([id, transition]) => {
        let rect = document.getElementById(id);
        let enabled = canFire(id);
        let inhibited = isInhibited(id);
        if (inhibited) {
            rect.setAttribute("class", "transition inhibited");
        } else if (enabled) {
            rect.setAttribute("class", "transition enabled");
        } else {
            rect.setAttribute("class", "transition");
        }
    })
    document.querySelector("svg").appendChild(fragment);
}

function resetPetriNet() {
    Object.entries(petriNet.places).forEach(([, place]) => {
        place.tokens = [...place.initial];
    });
    createElements();
    updateTokens();
    sequence = 0;
    window.parent.postMessage({
        type: 'reset',
        sequence: sequence,
        petriNet: petriNet
    }, '*');
}

function init() {
    let jsonSource = document.getElementById("source");
    if (jsonSource) {
        let metadata = jsonSource.textContent.trim();
        try {
            petriNet = JSON.parse(metadata);
            console.log(petriNet)
            createElements();
            updateTokens();
        } catch (error) {
            console.error("Failed to parse metadata: ", error);
        }
    } else {
        console.error("Metadata element not found");
    }

    window.addEventListener('message', (event) => {
        console.log("Received message from parent window: ", event.data);
        if (event.data.type === 'resize') {
            resizeSvg(event.data.width, event.data.height);
        }
        if (event.data.type === 'setModel') {
            try {
                // Expecting a JSON string for the petri net
                //petriNet = JSON.parse(event.data.model);
                petriNet = event.data.model;
                // check for tokens
                if (!petriNet.tokens) {
                    petriNet.tokens = ["black"]; // fallback to default
                }
                // populate place.tokens if not already set
                Object.entries(petriNet.places).forEach(([, place]) => {
                    if (!place.tokens || place.tokens.length === 0) {
                        place.tokens = [...place.initial]; // fallback to initial if tokens not set
                    }
                });
                createElements();
                updateTokens();
            } catch (error) {
                console.error("Failed to set model: ", error);
            }
        }
        if (event.data.type === 'restart') {
            resetPetriNet();
        }
    });
}

function resizeSvg(width, height) {
    const svg = document.querySelector("svg");
    if (svg) {
        svg.setAttribute("viewBox", "0 0 " + width + " " + height); // set viewBox
        svg.setAttribute("width", width); // set width
        svg.setAttribute("height", height); // set height
    } else {
        console.error("SVG element not found for resizing");
    }
}

window.addEventListener('keydown', function(event) {
    if (event.key === 'Escape' || event.key === 'x' || event.key === 'X') {
        resetPetriNet(); // Reset the Petri net when 'x' is pressed
    }
});

window.addEventListener('message', (event) => {
    if (event.data.type === 'resize') {
        resizeSvg(event.data.width, event.data.height);
    }
    if (event.data.type === 'setModel') {
        try {
            // Expecting a JSON string for the petri net
            //petriNet = JSON.parse(event.data.model);
            petriNet = event.data.model;
            createElements();
            updateTokens();
        } catch (error) {
            console.error("Failed to set model: ", error);
        }
    }
    if (event.data.type === 'restart') {
        resetPetriNet();
    }
});

window.addEventListener('load', init);
document.addEventListener('DOMContentLoaded', init);
</script>
</svg>

    <br/>
    <button id="playBtn">Play</button>
    <br/>
    <textarea id="source" rows="30" cols="80" >{
  "modelType": "PetriNet",
  "version": "v1",
  "tokens": ["black"],
  "places": {
    "place0": { "offset": 0, "initial": [1], "capacity": [3], "x": 130, "y": 207 }
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
}</textarea>
`
