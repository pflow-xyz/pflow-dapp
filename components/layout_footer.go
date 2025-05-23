package components

type FooterData struct {
	Analytics  bool
	AssetsPath string
	Sections   []FooterSection
}

type FooterLink struct {
	Label string
	URL   string
}

type FooterSection struct {
	Title string
	Links []FooterLink
}

func EnrichFooterData(data FooterData) FooterData {
	data.Sections = []FooterSection{
		{
			Title: "Footer navigation",
			Links: []FooterLink{
				{Label: "About", URL: "/about"}, // FIXME
				{Label: "Docs", URL: "https://docs.gno.land/"},
				{Label: "Faucet", URL: "https://faucet.gno.land/"},
				{Label: "Blog", URL: "https://blog.stackdump.com"},
				{Label: "Status", URL: "#"},
			},
		},
		{
			Title: "Social media",
			Links: []FooterLink{
				{Label: "GitHub", URL: "https://github.com/pflow-xyz/pflow-dapp"},
				{Label: "Twitter", URL: "https://x.com/stackdump_eth"},
				{Label: "Mastodon", URL: "https://fosstodon.org/@stackdump"},
				{Label: "Warpcast", URL: "https://warpcast.com/stackdump.eth"},
			},
		},
		{
			Title: "Legal",
			Links: []FooterLink{
				{Label: "Terms", URL: "https://github.com/gnolang/gno/blob/master/LICENSE.md"},
				{Label: "Privacy", URL: "https://github.com/gnolang/gno/blob/master/LICENSE.md"},
			},
		},
	}

	return data
}
