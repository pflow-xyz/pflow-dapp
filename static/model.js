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
            console.error(`Source or target not found for arc: ${arc}`);
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
        console.error(`Transition '${id}' not found in petriNet.transitions`);
        return;
    } else if (inhibited) {
        console.warn(`Transition '${id}' is inhibited`);
        return;
    } else if (!enabled) {
        console.warn(`Transition '${id}' is not enabled`);
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
    let metadataElement = document.getElementById("metadata");
    if (metadataElement) {
        let metadata = metadataElement.textContent.trim();
        try {
            petriNet = JSON.parse(metadata);
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
        svg.setAttribute("viewBox", `0 0 ${width} ${height}`);
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