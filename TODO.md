WIP
---

#### POC for alt-hosted gno.land web API

BACKLOG
-------

- [ ] fix initial render issue w/ pflow frame
- [ ] for petrinet frame: fix style issue for outer svgCanvas

DONE
----

- RE: tag design - going with a agnostic codefence approach '```gnomark {json} ```'
- custom gnomark tags MUST contain 'gnoMark' key and be valid json
    - [x] Consider Behavior / Thematic Tag designs - 
        - Behavioral Tags (what to do): <pflow-run>, <gno-exec>, <grid-editor>
        - Thematic/Domain Tags (how to render or interpret): <sprite>, <petri-net>, <pflow-dev>
     

ICEBOX
------
- [ ] add wf-net runner - use petri-nets to design processes with preconditions
  - [ ] add corresponding state machine model to the on-chain gno code
