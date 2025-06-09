package metamodel

import (
	"net/url"
	"strings"

	"gno.land/p/demo/ufmt"
)

// TokenType represents multiple token types as a slice of integers.
type TokenType []int64

func (tt TokenType) String() string {
    if len(tt) == 0 {
        return "[]"
    }
    var sb strings.Builder
    sb.WriteString("[")
    for i, v := range tt {
        if i > 0 {
            sb.WriteString(", ")
        }
        sb.WriteString(ufmt.Sprintf("%d", v))
    }
    sb.WriteString("]")
    return sb.String()
}

// T creates a TokenType from a list of integers or strings.
func T(t ...interface{}) TokenType {
	ts := make(TokenType, len(t))
	for i, v := range t {
		switch v := v.(type) {
		case int:
			ts[i] = int64(v)
		case int64:
			ts[i] = v
		case string:
			ts[i] = 1
		default:
			ts[i] = -1 // Default to -1 for unsupported types.
		}
	}

	return ts
}

// S creates a TokenType state vector from a list of TokenType.
func S(ts ...interface{}) []TokenType {
	state := make([]TokenType, len(ts))
	for i, v := range ts {
		state[i] = T(v)
	}
	return state
}

// Place represents a place in the Petri net.
type Place struct {
	Label    string    // Label of the place.
	Offset   int       // Offset of the place in the Petri net.
	Tokens   TokenType // Current number of tokens for each type.
	Initial  TokenType // Initial number of tokens for each type.
	Capacity TokenType // Maximum capacity for each token type (0 = unlimited).
	X        int       // X coordinate of the place.
	Y        int       // Y coordinate of the place.
}

// Arrow represents an arc in the Petri net.
type Arrow struct {
	Source  string    // Source place or transition.
	Target  string    // Target place or transition.
	Weight  TokenType // Weight for each token type.
	Inhibit bool      // Indicates if the arc inhibits the transition.
}

// Transition represents a transition in the Petri net.
type Transition struct {
	Label  string // Label of the transition.
	Offset int    // Offset of the transition in the Petri net.
	X      int    // X coordinate of the transition.
	Y      int    // Y coordinate of the transition.
}

// Pflow represents a Petri net model.
type Pflow struct {
	Places      map[string]Place      // Map of places.
	Transitions map[string]Transition // Map of transitions.
	Arrows      []Arrow               // List of arcs.
}

func (model *Pflow) State() []TokenType {
	state := make([]TokenType, len(model.Places))
	for _, place := range model.Places {
		state[place.Offset] = place.Tokens
	}
	return state
}

// TODO: try this out w/ testing
func Execute(state []TokenType, model *Pflow, action string) ([]TokenType, bool) {
	newState := make([]TokenType, len(state))
	copy(newState, state)

	for _, arc := range model.Arrows {
		if arc.Target == action {
			sourceTokens := model.Places[arc.Source].Tokens
			for i, weight := range arc.Weight {
				if sourceTokens[i] < weight {
					return state, false // Not enough tokens.
				}
				sourceTokens[i] -= weight
			}
		} else if arc.Source == action {
			targetTokens := model.Places[arc.Target].Tokens
			for i, weight := range arc.Weight {
				targetTokens[i] += weight
				if model.Places[arc.Target].Capacity[i] > 0 && targetTokens[i] > model.Places[arc.Target].Capacity[i] {
					return state, false // Exceeds capacity.
				}
			}
		}
	}

	return newState, true
}

func (model *Pflow) ToSvg() string {
	var sb strings.Builder
	sb.WriteString("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"800\" height=\"600\">\n")

	// Define arrow markers
	sb.WriteString(`
        <defs>
            <marker id="arrow" markerWidth="22.5" markerHeight="12" refX="9" refY="6.5" orient="auto">
                <path d="M3,1.5 L3,12 L10.5,6 L3,1.5"/>
            </marker>
            <marker id="inhibit" markerWidth="30" markerHeight="16" refX="10" refY="8.5" orient="auto">
                <circle cx="8" cy="9" r="4"/>
            </marker>
        </defs>
    `)

	// Draw places
	for _, place := range model.Places {
		tokens := place.Tokens
		sb.WriteString(ufmt.Sprintf("<circle cx=\"%d\" cy=\"%d\" r=\"20\" fill=\"black\" />\n", place.X, place.Y))
		for i, token := range tokens {
			if token > 0 {
				sb.WriteString(ufmt.Sprintf("<text x=\"%d\" y=\"%d\" font-size=\"12\" fill=\"white\">%d</text>\n", place.X-10+i*20, place.Y+5, token))
			}
		}
	}

	// Draw transitions
	for _, transition := range model.Transitions {
		sb.WriteString(ufmt.Sprintf("<rect x=\"%d\" y=\"%d\" width=\"40\" height=\"20\" fill=\"gray\" />\n", transition.X, transition.Y))
	}

	// Draw arrows
	for _, arrow := range model.Arrows {
		sourceX := model.Places[arrow.Source].X
		sourceY := model.Places[arrow.Source].Y
		targetX := model.Places[arrow.Target].X
		targetY := model.Places[arrow.Target].Y
		marker := "arrow"
		if arrow.Inhibit {
			marker = "inhibit"
		}
		sb.WriteString(ufmt.Sprintf("<line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" stroke=\"black\" marker-end=\"url(#%s)\" />\n", sourceX, sourceY, targetX, targetY, marker))
	}

	sb.WriteString("</svg>")
	return sb.String()
}

func (model *Pflow) ToDataUrl() string {
	return "data:image/svg+xml;utf8," + url.PathEscape(model.ToSvg())
}

func (model *Pflow) ToGnoMark() string {
	var sb strings.Builder
	sb.WriteString("{\n")
	sb.WriteString(`  "gnoMark": "petrinet",` + "\n")
	sb.WriteString(`  "petrinet": ` + model.ToJson() + "\n")
	sb.WriteString("}")
	return sb.String()
}

func (model *Pflow) ToJson() string {
	var sb strings.Builder
	sb.WriteString("{\n")
	sb.WriteString(`  "modelType": "PetriNet",` + "\n")
	sb.WriteString(`  "version": "v1",` + "\n")
	sb.WriteString(`  "tokens": ["black"],` + "\n")
	sb.WriteString(`  "places": {` + "\n")
	placeCount := len(model.Places)
	i := 0
	for label, place := range model.Places {
		sb.WriteString(ufmt.Sprintf(`    "%s": { "offset": %d, "initial": %v, "capacity": %v, "x": %d, "y": %d }`,
			label, place.Offset, place.Initial, place.Capacity, place.X, place.Y))
		if i < placeCount-1 {
			sb.WriteString(",\n")
		} else {
			sb.WriteString("\n")
		}
		i++
	}
	sb.WriteString("  },\n")
	sb.WriteString("  \"transitions\": {\n")
	transitionCount := len(model.Transitions)
	i = 0
	for label, transition := range model.Transitions {
		sb.WriteString(ufmt.Sprintf(`    "%s": { "x": %d, "y": %d }`,
			label, transition.X, transition.Y))
		if i < transitionCount-1 {
			sb.WriteString(",\n")
		} else {
			sb.WriteString("\n")
		}
		i++
	}
	sb.WriteString("  },\n")
	sb.WriteString("  \"arcs\": [\n")
	for i, arc := range model.Arrows {
		sb.WriteString(ufmt.Sprintf(`    { "source": "%s", "target": "%s", "weight": %v`,
			arc.Source, arc.Target, arc.Weight))
		if arc.Inhibit {
			sb.WriteString(", \"inhibit\": true")
		}
		sb.WriteString(" }")
		if i < len(model.Arrows)-1 {
			sb.WriteString(",\n")
		} else {
			sb.WriteString("\n")
		}
	}
	sb.WriteString("  ]\n")
	sb.WriteString("}")
	return sb.String()
}
type WebHost struct {
	Base string
	Tag  string
	Path string
}

func (h *WebHost) Cdn() string {
	return h.Base + h.Tag + h.Path
}

type SourceProvider = func(path string) string

func templateHtml(key, value string, s SourceProvider, path string) (out string) {
	out = strings.ReplaceAll(htmlContent, key, value)
	return strings.ReplaceAll(out, "{SOURCE}", s(path))
}

func Html(w *WebHost, s SourceProvider, path string) string {
	return templateHtml("{CDN}", w.Cdn(), s, path)
}

var htmlContent = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>pflow | metamodel</title>
</head>
<body>
    <petri-net>
    {SOURCE}
    </petri-net>
    <script src="{CDN}petri-net.js"></script>
</body>
</html>
`
