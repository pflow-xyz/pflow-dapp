class PetriNet extends HTMLElement {
    constructor() {
        super();
        this.svgId = 'petrinetFrame_' + Math.random().toString(36).substring(2, 15);
        this.attachShadow({mode: 'open'});
        this.shadowRoot.innerHTML = `
            <style>
                :host {
                    display: block;
                    width: 100%;
                    height: 100%;
                }
                svg {
                    width: 100%;
                    height: 100%;
                }
                .place { fill: #ffffff; stroke: #000000; stroke-width: 1.5; }
                .transition { fill: #ffffff; stroke: #000000; stroke-width: 1.5; cursor: pointer; user-select: text; }
                .transition.enabled { fill: #62fa75; }
                .transition.inhibited { fill: #fab5b0; stroke: #000000; stroke-width: 1.5; cursor: pointer; user-select: text; }
                .arc { stroke: #000000; stroke-width: 1; }
                .label { font-size: small; font-family: sans-serif; fill: #000000; user-select: none; }
                .token { fill: #000000; stroke: gray; stroke-width: 0.5; }
                .tokenSmall { font-size: small; user-select: none; font-weight: bold; }
            </style>
            <svg id="${this.svgId}" xmlns="http://www.w3.org/2000/svg" width="400" height="400" viewBox="0 0 400 400" >
            </svg>
        `;
    }

    connectedCallback() {
        const source = this.innerHTML.trim();
        if (!source) {
            console.error('No source provided in the innerHTML of <petri-net>');
            return;
        }

        let petriNet;
        try {
            petriNet = JSON.parse(source);
        } catch (error) {
            console.error('Error parsing Petri Net JSON:', error);
            return;
        }

        this.renderPetriNet(petriNet);
    }

    arcDefs() {
        // Re-add <defs> section
        const defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs');
        defs.innerHTML = `
            <marker id="markerArrow1" markerWidth="22.5" markerHeight="12" refX="9" refY="6.5" orient="auto">
                <path d="M3,1.5 L3,12 L10.5,6 L3,1.5"/>
            </marker>
            <marker id="markerInhibit1" markerWidth="30" markerHeight="16" refX="10" refY="8.5" orient="auto">
                <circle cx="8" cy="9" r="4"/>
            </marker>
        `;

        return defs
    }

    renderPetriNet(petriNet) {
        const svg = this.shadowRoot.querySelector(`#${this.svgId}`);
        if (!svg) {
            console.error('SVG element not found', this.svgId);
            return;
        }
        while (svg.firstChild) {
            svg.removeChild(svg.firstChild);
        }
        svg.appendChild(this.arcDefs());

        const fragment = document.createDocumentFragment();
        petriNet.arcs.forEach(arc => this.renderArc(fragment, arc, petriNet));
        Object.entries(petriNet.places).forEach(([id, place]) => this.renderPlace(fragment, id, place));
        Object.entries(petriNet.transitions).forEach(([id, transition]) => this.renderTransition(fragment, id, transition));

        svg.appendChild(fragment);
    }

    renderArc(fragment, arc, petriNet) {
        const source = petriNet.places[arc.source] || petriNet.transitions[arc.source];
        const target = petriNet.places[arc.target] || petriNet.transitions[arc.target];
        if (!source || !target) {
            console.error('Source or target not found for arc:', arc);
            return;
        }

        // Calculate direction vector
        const dx = target.x - source.x;
        const dy = target.y - source.y;
        const length = Math.sqrt(dx * dx + dy * dy);

        // Shorten the arrow by reducing the endpoint
        const shortenFactor = 24; // Adjust this value to control arrow shortening
        const x2 = target.x - (dx / length) * shortenFactor;
        const y2 = target.y - (dy / length) * shortenFactor;

        const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
        line.setAttribute('x1', source.x);
        line.setAttribute('y1', source.y);
        line.setAttribute('x2', x2);
        line.setAttribute('y2', y2);
        line.setAttribute('class', 'arc');

        // Add arrowhead or inhibitor marker
        if (arc.inhibit) {
            line.setAttribute('marker-end', 'url(#markerInhibit1)');
        } else {
            line.setAttribute('marker-end', 'url(#markerArrow1)');
        }

        fragment.appendChild(line);

        let midX = (source.x + x2) / 2;
        let midY = (source.y + y2) / 2;

        const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
        text.setAttribute('x', midX);
        text.setAttribute('y', midY);
        text.setAttribute('class', 'label');
        text.textContent = arc.weight[0];
        fragment.appendChild(text);
    }

    renderPlace(fragment, id, place) {
        const circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
        circle.setAttribute('cx', place.x);
        circle.setAttribute('cy', place.y);
        circle.setAttribute('r', '16');
        circle.setAttribute('class', 'place');
        fragment.appendChild(circle);

        const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
        text.setAttribute('x', place.x - 18);
        text.setAttribute('y', place.y - 20);
        text.setAttribute('class', 'label');
        text.textContent = id;
        fragment.appendChild(text);
    }

    renderTransition(fragment, id, transition) {
        const rect = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
        rect.setAttribute('x', transition.x - 15);
        rect.setAttribute('y', transition.y - 15);
        rect.setAttribute('width', '30');
        rect.setAttribute('height', '30');
        rect.setAttribute('class', 'transition');
        fragment.appendChild(rect);

        const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
        text.setAttribute('x', transition.x - 15);
        text.setAttribute('y', transition.y - 20);
        text.setAttribute('class', 'label');
        text.textContent = id;
        fragment.appendChild(text);
    }
}

customElements.define('petri-net', PetriNet);