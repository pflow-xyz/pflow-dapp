package gnomark

import (
	"encoding/json"
	"strings"
)

var (
	gnoFrameWebHost = &WebHost{
		Base: "https://cdn.jsdelivr.net/gh/pflow-xyz/pflow-dapp@",
		Tag:  "0.1.0",
		Path: "/static/",
	}

	defaultFrame = Frame{
		Version:               "0.1.0",
		Name:                  "GnoFrame",
		IconURL:               gnoFrameWebHost.Cdn() + "gno-frame.png",
		HomeURL:               "https://gno.land",
		ImageURL:              gnoFrameWebHost.Cdn() + "gno-frame.png",
		ButtonTitle:           "GnoFrame",
		SplashImageURL:        gnoFrameWebHost.Cdn() + "gno-frame.png",
		SplashBackgroundColor: "#ffffff",
		WebhookURL:            "https://gno.land/webhook",
	}
)

func (f Frame) ToJson() []byte {
	b, err := json.MarshalIndent(f, "", "  ")
	if err != nil {
		panic(err)
	}
	return b
}

type AccountAssociation struct {
	Header    string `json:"header"`
	Payload   string `json:"payload"`
	Signature string `json:"signature"`
}

type Frame struct {
	Version               string `json:"version"`
	Name                  string `json:"name"`
	IconURL               string `json:"iconUrl"`
	HomeURL               string `json:"homeUrl"`
	ImageURL              string `json:"imageUrl"`
	ButtonTitle           string `json:"buttonTitle"`
	SplashImageURL        string `json:"splashImageUrl"`
	SplashBackgroundColor string `json:"splashBackgroundColor"`
	WebhookURL            string `json:"webhookUrl"`
}

type FrameData struct {
	AccountAssociation AccountAssociation `json:"accountAssociation"`
	Frame              Frame              `json:"frame"`
}

func gnoFrameHtml(key, value string, content string) (out string) {
	out = strings.ReplaceAll(gnoFrameTemplate, key, value)
	return strings.ReplaceAll(out, "{CONTENT}", content)
}

func gnoFrameRender(_ string) string {
	// FIXME: parse content instead of using defaultFrame
	content := string(defaultFrame.ToJson())
	return gnoFrameHtml("{CDN}", gnoFrameWebHost.Cdn(), content)
}

// REVIEW: web component support
var gnoFrameTemplate = `
<style type="text/css">
 @import url("{CDN}gno-frame.css");
</style>
<gno-frame>

{CONTENT}

</gno-frame>
<script src="{CDN}gno-frame.js"></script>
`
