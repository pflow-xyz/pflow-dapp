WIP
---

#### POC for alt-hosted gno.land web API

- [ ] remove hardcoded paths

    cmd/gnoserve/app.go:	examplesDir := filepath.Join("./examples/")
    cmd/gnoserve/app_config.go:	// Users default
    cmd/gnoserve/command_local.go:		exampleRoot := filepath.Join("/Users/myork/Workspace/gno-public-service/examples")
    cmd/gnoserve/setup_web.go:	cfg.AssetsDir = "/Users/myork/Workspace/gno-public-service/public"

BACKLOG
-------
- [ ] deploy a compatible interface to gno.and and add a registry
- [ ] try out gno functions (call out to realm to render template) - as MD extensions
- [ ] remove pflow icon and name - replace with generic placeholders
- 
- [ ] build a template mechanism that depends on functions deployed to gno.land
- [ ] support image hosting use case from realm /r/stackdump/www /r/stackdump/bmp:filename.jpg
- [ ] try 250*250 bmp grid - png rendering

- [ ] make About page configurable from gno.land code
- [ ] try out "HyperRealm" approach - get-w/-content-in-header as render plugin - Why not do a post??
      could have a 'hosted' version of the goldmark plugin so others may depend on this node for rendering
- [ ] fix style issue for outer svgCanvas
- 
ICEBOX
------
- [ ] could we depend on gnoweb and/or gnodev in a better way?

- [ ] consider implementing a frontend-only solution to template rendering
      we could still lint the json body on the server side and then render it on the client side
      https://developer.mozilla.org/en-US/docs/Web/API/Web_components/Using_custom_elements#implementing_a_custom_element

- [ ] refine dependencies on gnodev - eventually make a first-class api to host 3rd party plugins
- [ ] obey TTL set in gno.land code - and/or just have a default for rendering new blocks that involve calls to gnoland
