package schema



// REVIEW: consider addinga  way to register new schemas or terms dynamically from other realms

func Render(_ string) string {
    return "```gnomark\n" +
        "Schema000 package provides data structures and methods for schema.org compliant data.\n" +
        "Use it to create structured data in JSON format for web applications.\n" +
        "```"
}