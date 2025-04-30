package gnomark

// REVIEW: consider moving this to a config
type WebHost struct {
	Base string
	Tag  string
	Path string
}

func (h *WebHost) Cdn() string {
	return h.Base + h.Tag + h.Path
}

// TODO: is there a common structure for js based web hosts?

// TODO: is there a common structure for gno-lang registered templates?
