package gnomark

import (
	"encoding/json"
	"github.com/yuin/goldmark"
	"github.com/yuin/goldmark/ast"
	"github.com/yuin/goldmark/parser"
	"github.com/yuin/goldmark/renderer"
	"github.com/yuin/goldmark/util"
)

var templateRegistry = map[string]func(string) string{
	"frame": gnoFrameRender,
	"html":  noHtmlMsg,
}

// gnoMarkRenderer renders the gomark fenced code block as HTML.
type gnoMarkRenderer struct{}

func (r *gnoMarkRenderer) RegisterFuncs(reg renderer.NodeRendererFuncRegisterer) {
	reg.Register(ast.KindFencedCodeBlock, r.renderGnoMarkBlock)
}

// getGnoMarkType extracts the gnoMark type from the JSON content.
func getGnoMarkType(jsonContent string) string {
	var data map[string]interface{}
	if err := json.Unmarshal([]byte(jsonContent), &data); err == nil {
		if gnoMarkType, ok := data["gnoMark"].(string); ok {
			return gnoMarkType
		}
	}
	return "html"
}

func (r *gnoMarkRenderer) renderGnoMarkBlock(w util.BufWriter, source []byte, node ast.Node, entering bool) (ast.WalkStatus, error) {
	if !entering {
		return ast.WalkContinue, nil
	}

	block, ok := node.(*ast.FencedCodeBlock)
	if !ok {
		return ast.WalkContinue, nil
	}

	// FIXME: .Text is deprecated
	err := renderCodeBlock(w, string(block.Language(source)), block.Text(source))

	return ast.WalkContinue, err
}

// gnoMarkExtension is the Goldmark extension for gomark fenced code blocks.
type gnoMarkExtension struct{}

func (e *gnoMarkExtension) Extend(m goldmark.Markdown) {
	m.Parser().AddOptions(parser.WithBlockParsers(
		util.Prioritized(parser.NewFencedCodeBlockParser(), 100),
	))
	m.Renderer().AddOptions(renderer.WithNodeRenderers(
		util.Prioritized(&gnoMarkRenderer{}, 100),
	))
}

// NewGnoMarkExtension creates a new gomark extension.
func NewGnoMarkExtension() *gnoMarkExtension {
	return &gnoMarkExtension{}
}

func isValidJson(data []byte) bool {
	var js json.RawMessage
	return json.Unmarshal(data, &js) == nil
}

func renderCodeBlock(w util.BufWriter, language string, source []byte) error {
	if !isValidJson(source) {
		_, _ = w.WriteString(noHtmlMsg(""))
		return nil
	}
	switch language {
	case "jsonld":
		return renderJsonLD(w, source)
	case "gnomark":
		return renderFrameTemplate(w, source)
	default:
		return renderFencedGeneric(w, source)
	}
}

func renderFencedGeneric(w util.BufWriter, source []byte) error {
	_, _ = w.WriteString(`<pre><code>`)
	_, _ = w.Write(source)
	_, _ = w.WriteString(`</code></pre>`)
	return nil
}

func renderJsonLD(w util.BufWriter, source []byte) error {
	_, _ = w.WriteString(`<script type="application/ld+json">`)
	_, _ = w.Write(source)
	_, _ = w.WriteString(`</script>`)
	return nil
}

func renderFrameTemplate(w util.BufWriter, source []byte) error {
	content := string(source)
	gnoMarkType := getGnoMarkType(content)
	template, ok := templateRegistry[gnoMarkType]
	if ok {
		_, _ = w.WriteString(template(content))
	} else {
		_, _ = w.WriteString("<pre><code>Unsupported gnoMark type</code></pre>")
	}
	return nil
}
