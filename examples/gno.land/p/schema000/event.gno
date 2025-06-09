package schema

// Event represents a schema.org Event. https://schema.org/Event
type Event struct {
	Context     string
	Type        string
	Name        string
	Description string
	StartDate   string
	EndDate     string
	Location    string
	TermSet     DefinedTermSet
}

// ToJson constructs the JSON string using string concatenation.
func (e Event) ToJson() string {
	json := "{"
	json += "\"@context\":\"" + e.Context + "\","
	json += "\"@type\":\"" + e.Type + "\","
	json += "\"name\":\"" + e.Name + "\","
	json += "\"description\":\"" + e.Description + "\","
	json += "\"startDate\":\"" + e.StartDate + "\","
	json += "\"endDate\":\"" + e.EndDate + "\","
	json += "\"location\":\"" + e.Location + "\","
	json += "\"termSet\":{"
	json += "\"@context\":\"" + e.TermSet.Context + "\","
	json += "\"@type\":\"" + e.TermSet.Type + "\","
	json += "\"name\":\"" + e.TermSet.Name + "\","
	json += "\"description\":\"" + e.TermSet.Description + "\","
	json += "\"hasDefinedTerm\":["
	for i, term := range e.TermSet.HasDefinedTerm {
		json += "{"
		json += "\"@type\":\"" + term.Type + "\","
		json += "\"name\":\"" + term.Name + "\","
		json += "\"description\":\"" + term.Description + "\","
		json += "\"inDefinedTermSet\":\"" + term.InDefinedTermSet + "\""
		json += "}"
		if i < len(e.TermSet.HasDefinedTerm)-1 {
			json += ","
		}
	}
	json += "]}"
	json += "}"
	json += "}"
	return json
}