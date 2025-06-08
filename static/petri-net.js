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
            <marker id="arrow" markerWidth="22.5" markerHeight="12" refX="9" refY="6.5" orient="auto">
                <path d="M3,1.5 L3,12 L10.5,6 L3,1.5"/>
            </marker>
            <marker id="inhibit" markerWidth="30" markerHeight="16" refX="10" refY="8.5" orient="auto">
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

    midMarker(source, target, arc) {
        const midX = (source.x + target.x) / 2;
        const midY = (source.y + target.y) / 2;

        // TODO: circle should be the color of the token being transferred
        const circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
        circle.setAttribute('cx', midX);
        circle.setAttribute('cy', midY);
        circle.setAttribute('r', '12'); // Adjust radius as needed
        circle.setAttribute('class', 'label-background'); // Add a class for styling
        circle.setAttribute('fill', '#f0f0f0'); // Shaded color
        circle.setAttribute('stroke', '#000000'); // Optional border
        circle.setAttribute('stroke-width', '1');

        const midMarker = document.createElementNS('http://www.w3.org/2000/svg', 'text');
        midMarker.setAttribute('x', midX);
        midMarker.setAttribute('y', midY + 4); // Adjust vertical alignment
        midMarker.setAttribute('class', 'label');
        midMarker.setAttribute('text-anchor', 'middle'); // Center text horizontally
        midMarker.textContent = arc.weight[0];

        const fragment = document.createDocumentFragment();
        fragment.appendChild(circle);
        fragment.appendChild(midMarker);

        return fragment;
    }

    renderArc(fragment, arc, petriNet) {
        const source = petriNet.places[arc.source] || petriNet.transitions[arc.source];
        const target = petriNet.places[arc.target] || petriNet.transitions[arc.target];
        if (!source || !target) {
            console.error('Source or target not found for arc:', arc);
            return;
        }

        const dx = target.x - source.x;
        const dy = target.y - source.y;
        const length = Math.sqrt(dx * dx + dy * dy);

        const shortenFactor = 24;
        const x2 = target.x - (dx / length) * shortenFactor;
        const y2 = target.y - (dy / length) * shortenFactor;

        const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
        line.setAttribute('x1', source.x);
        line.setAttribute('y1', source.y);
        line.setAttribute('x2', x2);
        line.setAttribute('y2', y2);
        line.setAttribute('class', 'arc');

        if (arc.inhibit) {
            line.setAttribute('marker-end', 'url(#inhibit)');
        } else {
            line.setAttribute('marker-end', 'url(#arrow)');
        }

        fragment.appendChild(line);
        fragment.appendChild(this.midMarker(source, {x: x2, y: y2}, arc));
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