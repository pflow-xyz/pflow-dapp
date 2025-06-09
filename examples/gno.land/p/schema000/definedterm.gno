package schema

// DefinedTerm represents a single term in the term set. https://schema.org/DefinedTerm
type DefinedTerm struct {
	Type            string
	Name            string
	Description     string
	InDefinedTermSet string
}

// DefinedTermSet represents the term set. https://schema.org/DefinedTermSet
type DefinedTermSet struct {
	Context       string
	Type          string
	Name          string
	Description   string
	HasDefinedTerm []DefinedTerm
}

// ToJson constructs the JSON string using string concatenation.
func (dts DefinedTermSet) ToJson() string {
	json := "{"
	json += "\"@context\":\"" + dts.Context + "\","
	json += "\"@type\":\"" + dts.Type + "\","
	json += "\"name\":\"" + dts.Name + "\","
	json += "\"description\":\"" + dts.Description + "\","
	json += "\"hasDefinedTerm\":["
	for i, term := range dts.HasDefinedTerm {
		json += "{"
		json += "\"@type\":\"" + term.Type + "\","
		json += "\"name\":\"" + term.Name + "\","
		json += "\"description\":\"" + term.Description + "\","
		json += "\"inDefinedTermSet\":\"" + term.InDefinedTermSet + "\""
		json += "}"
		if i < len(dts.HasDefinedTerm)-1 {
			json += ","
		}
	}
	json += "]}"
	return json
}

func (dts DefinedTermSet) ToSvg() string {
    svg := "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 600 400\">"
    svg += "<text x=\"10\" y=\"20\" font-size=\"16\" font-family=\"Arial\">DefinedTermSet: " + dts.Name + "</text>"
    svg += "<text x=\"10\" y=\"40\" font-size=\"14\" font-family=\"Arial\">Description: " + dts.Description + "</text>"
    yOffset := 60
    for _, term := range dts.HasDefinedTerm {
        svg += "<text x=\"10\" y=\"" + string(yOffset) + "\" font-size=\"12\" font-family=\"Arial\">Term: " + term.Name + "</text>"
        yOffset += 20
    }
    svg += "</svg>"
    return svg
}