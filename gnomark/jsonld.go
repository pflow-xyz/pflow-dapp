package gnomark

import "encoding/json"

// structuredData is a package that provides functionality to generate structured data in JSON-LD format for use in web pages.
// TODO: Implement structured data generation functions here.

// TODO: add asserts:
// top level '@context' is always 'https://schema.org'
// top level '@type' is always a valid schema.org type
// that the structured data is valid JSON-LD
// that the structured data is properly formatted and escaped

func toJson(data map[string]interface{}) string {
	jsonData, err := json.MarshalIndent(data, "", "  ")
	if err != nil {
		panic(err) // Handle error appropriately in production code
	}
	return string(jsonData)
}

// FIXME: make suitable structure that users could register callback from realm...
func StructuredDataHtmlFragment(key, value string, data map[string]interface{}) (out string) {
	jsonData := toJson(data)
	out = "<script type=\"application/ld+json\">\n" + jsonData + "\n</script>"
	return out
}
