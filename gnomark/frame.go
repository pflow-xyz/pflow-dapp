package gnomark

import (
	"encoding/json"
	"strings"
)

var (
	gnoFrameWebHost = &WebHost{
		Base: "https://cdn.jsdelivr.net/gh/pflow-xyz/pflow-dapp@",
		Tag:  "0.2.0",
		Path: "/static/",
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

func gnoFrameRender(content string) string {
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

const badFrame = `<svg xmlns="http://www.w3.org/2000/svg" width="399.999" height="399.473" viewBox="0 0 105.833 105.694"><path d="m24.277 124.953-.507.338c-.278.185-.622.57-.764.852-.244.486-.257 3.409-.25 51.579.007 49.329.016 51.085.282 51.687.19.429.453.716.846.924.57.301.662.3 51.836.308l51.263.006.555-.312c.305-.17.667-.501.804-.732.23-.392.247-4.057.245-51.817-.002-48.614-.016-51.419-.262-51.837-.142-.243-.493-.566-.778-.719-.503-.269-2.062-.277-51.895-.277zm3.454 4.838h96.018v95.869l-21.81.017c-11.994.01-21.64-.01-21.436-.044 4.477-.726 6.148-1.044 8.056-1.53 5.872-1.499 10.493-3.516 13.884-6.06 2.157-1.62 3.517-3.397 4.413-5.767.421-1.116.518-1.249 1.305-1.797 1.208-.841 2.098-1.692 2.407-2.305.418-.828.957-3.53.952-4.77a8.2 8.2 0 0 0-.893-3.614c-.648-1.28-2.775-3.165-4.638-4.113-.352-.178-.665-.405-.697-.504s-.37-1.35-.753-2.782c-.87-3.248-1.282-4.576-2.498-8.042-2.272-6.474-5.602-14.57-8.853-21.523-2.173-4.644-3.6-8.455-4.291-11.447-.724-3.138-.63-6.233.337-11.168.661-3.37.656-4.556-.023-5.669-1.136-1.86-3.942-2.088-6.97-.57a23 23 0 0 0-2.08 1.218c-2.806 1.882-8.254 6.994-11.143 10.454-9.807 11.748-19.053 30.51-23.503 47.688l-.495 1.912-1.06.715c-2.363 1.594-4.197 4.13-4.535 6.269-.27 1.707.245 4.55 1.056 5.822.436.685 2.017 2.268 2.728 2.735.235.153.466.573.677 1.227.671 2.088 1.624 3.51 3.34 4.988 4.425 3.81 12.904 6.956 22.708 8.429l1.86.28-22.07.013-22.068.013.037-47.972zm41.313 36.28h11.98l8.463 7.177v10.16l-8.463 7.178h-11.98l-8.462-7.178v-10.16zm-.016 5.448-2.023 1.716 6.006 5.094-6.006 5.093 2.023 1.716 6.006-5.094 6.006 5.094 2.023-1.716-6.005-5.093 6.005-5.094-2.023-1.716-6.006 5.093zm5.721 27.91c11.775-.092 22.913 2.417 26.697 6.556 1.123 1.23 1.45 2.008 1.457 3.45.004 1.06-.052 1.31-.496 2.212-2.375 4.824-11.032 8.285-22.57 9.023h-.001c-9.595.613-19.668-1.006-26.023-4.182-2.595-1.298-4.973-3.374-5.723-4.997-.508-1.1-.621-2.545-.278-3.57 1.119-3.358 6.544-6.032 15.2-7.495 3.817-.645 7.812-.965 11.737-.996" style="fill:#000;stroke-width:.562641" transform="translate(-22.754 -124.953)"/></svg>`

func noHtmlMsg(_ string) string {
	return "<div id=\"gnoMarkParseError\"><h2> GnoMark: failed to parse json </h2>\n\n" + badFrame
}
