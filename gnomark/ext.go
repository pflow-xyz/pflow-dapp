package gnomark

import (
	"github.com/gnolang/gno/gno.land/pkg/gnoweb"
	mathjax "github.com/litao91/goldmark-mathjax"
	figure "github.com/mangoumbrella/goldmark-figure"
	img64 "github.com/tenkoh/goldmark-img64"
	"net/http"

	"github.com/yuin/goldmark"
	"github.com/yuin/goldmark/parser"
	"github.com/yuin/goldmark/renderer"
	"github.com/yuin/goldmark/util"
	"go.abhg.dev/goldmark/mermaid"
)

// GnoMarkExtension is the Goldmark extension adding block parsers and renderers
// for GnoMark blocks: <gno-mark>...</gno-mark>
type GnoMarkExtension struct {
	Client *gnoweb.HTMLWebClient
}

func (e *GnoMarkExtension) Extend(m goldmark.Markdown) {
	(&mermaid.Extender{
		RenderMode:   0,
		Compiler:     nil,
		CLI:          nil,
		MermaidURL:   "",
		ContainerTag: "",
		NoScript:     false,
		Theme:        "",
	}).Extend(m) // mermaid

	// FIXME: it's not clear if this is working as intended
	_ = mathjax.MathJax
	//mathjax.MathJax.Extend(m) // mathjax
	img64.Img64.Extend(m)

	// Register the gnoMark parser and renderer
	m.Parser().AddOptions(parser.WithBlockParsers(
		util.Prioritized(&gnoMarkParser{}, 500),
	))
	m.Parser().AddOptions(parser.WithAutoHeadingID())
	m.Renderer().AddOptions(renderer.WithNodeRenderers(
		util.Prioritized(&gnoMarkRenderer{client: e.Client}, 500),
	))
	// Awesome! caches the image data in the HTML
	m.Renderer().AddOptions(img64.WithFileReader(img64.AllowRemoteFileReader(http.DefaultClient)))
	figure.Figure.Extend(m)

}
