package pflow

var frame = `
    {
        "gnoMark": "frame"
        "frame": "petri-net",
    }
`

var gnoMarkStart = "<gno-mark>"
var gnoMarkEnd = "</gno-mark>"

func Render(_ string) string {
	return gnoMarkStart + "\n\n" + frame + "\n\n" + gnoMarkEnd
}
