WIP
---

#### POC for alt-hosted gno.land web API

BACKLOG
-------
- [ ] add a  means to let users add gnoweb endpoints to an online registry
- 
- [ ] Build image index on chain & add widget to reference on-chain data 
      - use this system to track, view, and deploy petri-net models

- [ ] Consider Behavior / Thematic Tag designs
    - Behavioral Tags (what to do): <pflow-run>, <gno-exec>, <grid-editor>
    - Thematic/Domain Tags (how to render or interpret): <sprite>, <petri-net>, <pflow-dev>

ICEBOX
------
- [ ] for petrinet viewer: fix style issue for outer svgCanvas
- 
- [ ] deploy a compatible interface for gno-mark widget system to gno.and and add a registry

- [ ] try out gno functions (call out to realm to render template) - as MD extensions
- [ ] build a template mechanism that depends on functions deployed to gno.land

- [ ] try 250*250 bmp grid - png rendering

- [ ] make About page configurable from gno.land code
- [ ] try out "HyperRealm" approach - get-w/-content-in-header as render plugin - Why not do a post??
      could have a 'hosted' version of the goldmark plugin so others may depend on this node for rendering


- [ ] Consider Refactor could we depend on gnoweb and/or gnodev in a better way?

- [ ] consider implementing a frontend-only solution to template rendering
      we could still lint the json body on the server side and then render it on the client side
      https://developer.mozilla.org/en-US/docs/Web/API/Web_components/Using_custom_elements#implementing_a_custom_element

- [ ] refine dependencies on gnodev - eventually make a first-class api to host 3rd party plugins
- [ ] obey TTL set in gno.land code - and/or just have a default for rendering new blocks that involve calls to gnoland

DONE
----
- [x] support image hosting use case from realm /r/stackdump/www /r/stackdump/bmp:filename.jpg 
      - Used the img64 markdown plugin to host images embedded in page
