
// set the origin for postMessage
const origin = "*";

// Get the model data from the meta tag
let model = {};
let eventLog = [];
let nonce = 0;
let modelData = document.querySelector('#source');
if (!modelData) {
    console.error('Model data not found in the meta tag.');
}
try {
    if (modelData && modelData.textContent) {
	// Parse the JSON data
	model = JSON.parse(modelData.textContent);
    } else {
	console.error('Model data is empty or invalid.');
    }
    if (typeof model !== 'object' || !model) {
	console.error('Parsed model is not an object:', model);
    }
} catch (e) {
    console.error('Error parsing model data:', e);
}

function init() {
    const svg = document.getElementById('svgObject');
    if (!svg || !svg.contentWindow) {
	console.error('SVG object not found or not loaded yet.');
	return;
    }
    svg.contentWindow.postMessage({ type: 'setModel', model: model }, origin); // Send the model to the SVG
    const playBtn = document.getElementById('playBtn');
    const modelData = document.getElementById('source');

    function reset() {
	if (modelData) {
	    modelData.style.display = 'block';
	}
	// Change the status text
	const statusText = document.querySelector('#status text');
	if (statusText) {
	    statusText.textContent = 'Status: Restarted';
	}
	// set timeout for 1 second to change the status back to running
	setTimeout(() => {
	    const statusText = document.querySelector('#status text');
	    if (statusText) {
		statusText.textContent = 'Status: Running';
	    }
	}, 1000);
	nonce = 0;
	eventLog = [];
	RenderHistory();
    }

    function restart() {
	if (!svg.contentWindow) {
	    console.error('SVG contentWindow not available.');
	    return;
	}
	svg.contentWindow.postMessage({ type: 'restart' }, origin);
	reset()
    }

    playBtn.addEventListener('click', () => restart());

    // update model after edit in the textarea
    if (modelData) {
	modelData.addEventListener('input', function() {
	    try {
		const newModel = JSON.parse(modelData.value);
		if (typeof newModel === 'object' && newModel) {
		    model = newModel;
		    svg.contentWindow.postMessage({ type: 'setModel', model: model }, origin); // Send the updated model to the SVG
		    //console.log('Updated model:', model);
		} else {
		    //console.error('Invalid model format:', newModel);
		}
	    } catch (e) {
		//console.error('Error parsing model data:', e);
	    }
	});
    }

    function RenderHistory() {
	const fragment = document.createDocumentFragment();
	// history in reverse order

	eventLog.forEach((event, index) => {
	    const offset = 26
	    const newText = document.createElementNS("http://www.w3.org/2000/svg", "text");
	    newText.setAttribute('x', '10');
	    newText.setAttribute('y', `${offset + (eventLog.length - index) * 19-3}`);
	    // string pad 8 chars to left
	    newText.textContent = `${(index + 1).toString().padStart(3, '0')}.  ${event.transitionId}`;
	    newText.setAttribute('stroke', '#222');

	    const rect = document.createElementNS("http://www.w3.org/2000/svg", "rect");
	    rect.setAttribute('x', '0');
	    rect.setAttribute('y', `${offset+2 + index * 19}`);
	    rect.setAttribute('class', 'history item');
	    rect.setAttribute('fill', '#fff');
	    rect.setAttribute('rx', '5');
	    rect.setAttribute('ry', '5');
	    fragment.appendChild(rect);
	    fragment.appendChild(newText);
	});
	const history = document.getElementById('history');
	if (history) {
	    while (history.childNodes.length > 1) {
		history.removeChild(history.lastChild);
	    }
	    history.appendChild(fragment);
	}
    }

    window.addEventListener('message', function(event) {
	// REVIEW: by removing this check we allow cross origin interaction
	// if (event.origin !== window.location.origin) {
	//     console.error('Invalid origin:', event.origin);
	//     return;
	// }
	if (event.data.type === "reset") {
	    reset();
	}
	if (event.data.type === 'transitionFired') {
	    // KLUDGE getting notified 2x
	    if (nonce === event.data.sequence) {
		return;
	    } else {
		nonce = event.data.sequence;
	    }
	    // add to front
	    eventLog.push(event.data);
	    RenderHistory();
	    // hide the data
	    const modelData = document.getElementById('source');
	    if (modelData) {
		modelData.style.display = 'none';
	    }
	} else if (event.data.type === 'error') {
	    console.error('Error from SVG:', event.data.message);
	} else if (event.data.type === 'resize') {
	    render(svg);
	} else {
	    //console.log('Unknown message type:', event.data.type);
	}
    }, false);
    render(svg)
}

function render(svg) {
    const width = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
    svg.contentWindow.postMessage({ type: 'resize', width: width-15, height: 600 }, origin);
}

// FIXME doesn't scale properly on resize
//window.addEventListener('resize', render);
window.addEventListener('load', init);
document.addEventListener('DOMContentLoaded', init);
