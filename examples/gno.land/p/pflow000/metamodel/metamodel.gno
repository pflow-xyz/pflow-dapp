package metamodel

import (
	"net/url"
	"strings"

	"gno.land/p/demo/ufmt"
)

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
			ts[i] = -1
		}
	}
	return ts
}

func S(ts ...interface{}) []TokenType {
	state := make([]TokenType, len(ts))
	for i, v := range ts {
		state[i] = T(v)
	}
	return state
}

type Token struct {
	Type         string
	Name         string
	Ticker       string
	Denomination string
	Value        int64
}

type Place struct {
	ID          string
	Type        string
	Name        string
	Identifier  string
	Description string
	Offset      int
	Initial     []int
	Capacity    []int
	X           int
	Y           int
	Token       Token
	Tokens      TokenType
}

type Agent struct {
	Type string
	Name string
}

type Action struct {
	Type        string
	Agent       Agent
	Object      Token
	Recipient   Place
	Description string
}

type Transition struct {
	ID     string
	Type   string
	X      int
	Y      int
	Action Action
}

type Weight struct {
	Type  string
	Name  string
	Value int64
}

type Arrow struct {
	Type              string
	Name              string
	Description       string
	ArcType           string
	Function          string
	Source            map[string]string
	Target            map[string]string
	InhibitTransition bool
	Weight            []Weight
}

type PetriNet struct {
	Context     string
	Type        string
	ModelType   string
	Version     string
	Tokens      []string
	Places      map[string]Place
	Transitions map[string]Transition
	Arcs        []Arrow
}

type Pflow struct {
	Places      map[string]Place
	Transitions map[string]Transition
	Arrows      []Arrow
}

func (model *Pflow) State() []TokenType {
	state := make([]TokenType, len(model.Places))
	for _, place := range model.Places {
		state[place.Offset] = place.Tokens
	}
	return state
}

type MetaModel interface {
	Svg(string) string
	DataUrl(string) string
	Json(string) string
	GnoMark(string) string
}

type Model struct {
	ModelType   string
	Version     string
	Tokens      []string
	Places      map[string]Place
	Transitions map[string]Transition
	Arcs        []Arrow
}

func Schema() string {
	return schema
}

var schema = `
{
  "@context": "https://pflow.yz/schema",
  "@type": "PetriNet",
  "modelType": "PetriNet",
  "version": "v1",
  "tokens": ["black"],
  "places": {
    "place0": {
      "@id": "place0",
      "@type": "Place",
      "name": "User Wallet",
      "identifier": "place0",
      "description": "Holds user balance in native token",
      "offset": 0,
      "initial": [1],
      "capacity": [3],
      "x": 130,
      "y": 207,
      "token": {
        "@type": "PropertyValue",
        "name": "Token",
        "ticker": "ATOM",
        "denomination": "uatom"
      }
    }
  },
  "transitions": {
    "txn1": {
      "@id": "txn1",
      "@type": "Transition",
      "x": 227,
      "y": 112,
      "action": {
        "@type": "TransferAction",
        "agent": {
          "@type": "Person",
          "name": "System"
        },
        "object": {
          "@type": "PropertyValue",
          "name": "Token",
          "value": 3
        },
        "recipient": {
          "@type": "Place",
          "name": "place0"
        },
        "description": "System transfers 3 tokens to place0"
      }
    }
  },
  "arcs": [
    {
      "@type": "Arrow",
      "name": "Consumption Arc",
      "description": "Consumes 1 token from txn0 to place0",
      "source": { "@id": "txn0" },
      "target": { "@id": "place0" },
      "weight": [
        {
          "@type": "PropertyValue",
          "name": "black",
          "value": 1
        }
      ]
    },
    {
      "@type": "Arrow",
      "name": "Forward Arc",
      "description": "Moves 3 tokens from place0 to txn1",
      "source": { "@id": "place0" },
      "target": { "@id": "txn1" },
      "weight": [
        {
          "@type": "PropertyValue",
          "name": "black",
          "value": 3
        }
      ]
    },
    {
      "@type": "Arrow",
      "name": "Inhibitor Arc",
      "description": "Prevents txn2 from firing if place0 has 3 tokens",
      "arcType": "inhibitor",
      "function": "disableWhenTokensPresent",
      "source": { "@id": "txn2" },
      "target": { "@id": "place0" },
      "inhibitTransition": true,
      "weight": [
        {
          "@type": "PropertyValue",
          "name": "black",
          "value": 3
        }
      ]
    },
    {
      "@type": "Arrow",
      "name": "Inhibitor Arc",
      "description": "Blocks txn3 if place0 is not empty",
      "arcType": "inhibitor",
      "function": "disableWhenTokensPresent",
      "source": { "@id": "place0" },
      "target": { "@id": "txn3" },
      "inhibitTransition": true,
      "weight": [
        {
          "@type": "PropertyValue",
          "name": "black",
          "value": 1
        }
      ]
    }
  ]
}`


func Execute(state []TokenType, model *Pflow, action string) ([]TokenType, bool) {
	newState := make([]TokenType, len(state))
	for i := range state {
		newState[i] = append(TokenType(nil), state[i]...)
	}

	for _, arc := range model.Arrows {
		srcID := arc.Source["@id"]
		tgtID := arc.Target["@id"]

		if tgtID == action {
			src := model.Places[srcID]
			for i, weight := range arc.Weight {
				if newState[src.Offset][i] < weight.Value {
					return state, false
				}
				newState[src.Offset][i] -= weight.Value
			}
		} else if srcID == action {
			tgt := model.Places[tgtID]
			for i, weight := range arc.Weight {
				newState[tgt.Offset][i] += weight.Value
				if tgt.Capacity[i] > 0 && newState[tgt.Offset][i] > int64(tgt.Capacity[i]) {
					return state, false
				}
			}
		}
	}

	return newState, true
}

func (model *Pflow) ToSvg() string {
	var sb strings.Builder
	sb.WriteString("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"800\" height=\"600\">\n")
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

	for _, place := range model.Places {
		tokens := place.Tokens
		sb.WriteString(ufmt.Sprintf("<circle cx=\"%d\" cy=\"%d\" r=\"20\" fill=\"black\" />\n", place.X, place.Y))
		for i, token := range tokens {
			if token > 0 {
				sb.WriteString(ufmt.Sprintf("<text x=\"%d\" y=\"%d\" font-size=\"12\" fill=\"white\">%d</text>\n", place.X-10+i*20, place.Y+5, token))
			}
		}
	}

	for _, transition := range model.Transitions {
		sb.WriteString(ufmt.Sprintf("<rect x=\"%d\" y=\"%d\" width=\"40\" height=\"20\" fill=\"gray\" />\n", transition.X, transition.Y))
	}

	for _, arrow := range model.Arrows {
		src := model.Places[arrow.Source["@id"]]
		tgt := model.Places[arrow.Target["@id"]]
		marker := "arrow"
		if arrow.InhibitTransition {
			marker = "inhibit"
		}
		sb.WriteString(ufmt.Sprintf("<line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" stroke=\"black\" marker-end=\"url(#%s)\" />\n",
			src.X, src.Y, tgt.X, tgt.Y, marker))
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
			arc.Source["@id"], arc.Target["@id"], arc.Weight))
		if arc.InhibitTransition {
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

func templateHtml(key, value string, s SourceProvider, path string) string {
	out := strings.ReplaceAll(htmlContent, key, value)
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
