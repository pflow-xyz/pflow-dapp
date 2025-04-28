package gnomark

import "strings"

//  is an alternative to the js element  system.
// instead of declaring custom Html elements, we use a simple string replacement system.

var templateString = `
	
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>GnoFrame</title>
	<link rel="stylesheet" href="{CDN}gno-frame.css">
</head>
<body>
{CONTENT}
</body>
</html>
`

// REVIEW: this templat data could originate from registered realm functions on-chain
func StringTemplate(key, value string, content string) (out string) {
	out = strings.ReplaceAll(templateString, key, value)
	return strings.ReplaceAll(out, "{CONTENT}", content)
}
