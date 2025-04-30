package gnoframe

var (
	registry = &GnoObj{}
	gf       = &GnoFrame{}
)

func init() {
	registry.obj = map[string]interface{}{
		"index":         welcome,
		"sharing":       sharing,
		"frame":         gf.Render,
		"bestpractices": bestpractices,
	}
}

// Identity declaration for GnoFrame
// Users extending GnoFrame can implement the Component interface
// and adopt a new "gnoFrame": "gno-frame" key in their JSON metadata.
var frame = `
    {
        "name": "GnoFrame",
        "gnoMark": "frame",
        "gnoFrame": "gno-frame",
        "iconUrl": "favicon-32x32.png",
        "homeUrl": "https://gno.land",
        "imageUrl": "android-chrome-512x512.png",
        "buttonTitle": "GnoFrame",
        "splashImageUrl": "",
        "splashBackgroundColor": "#ffffff",
        "webhookUrl": "https://gno.land/webhook"
    }
`

type GnoFrame struct{}

var gnoMarkStart = "<gno-mark>"
var gnoMarkEnd = "</gno-mark>"

func (gf *GnoFrame) Render(props map[string]interface{}) string {
	// TODO: compute json from props
	_ = props
	return gnoMarkStart + "\n\n" + frame + "\n\n" + gnoMarkEnd
}

func (nob *GnoObj) Render(path string) string {
	if f, ok := nob.obj[path]; ok {
		switch f := f.(type) {
		case func(opts map[string]interface{}) string:
			opts := make(map[string]interface{})
			opts["path"] = path
			return f(opts)
		case func(string) string:
			return f(path)
		case func() string:
			return f()
		case string:
			return f
		default:
			return "unknown type"
		}
	}
	return "not found"
}

func Render(path string) string {
	switch path {
	case "":
		return registry.Render("index")
	default:
		return registry.Render(path)
	}
}
