#### gno.pflow.xyz

Composable models for web3

Gno.land is an exceptional platform for building composable models
Lambdas and callbacks are the key to building complex systems

These features along with a built-in markdown UX
Will allow us to build a large state machine to describe the language of web3

WIP
---
- [ ] update petri-net frame
  - [ ] update ToSvg to output same formatted svg as petri-net.js
  - [ ] READ-only views - (play/restart/live buttons added animation later)
  - [ ] output properly colorized i.e. should indicate active/inactive inhibited txns
  - [ ] update to support rendering > 1 petri-net in each page i.e. multiple codefences in a single markdown file
 

BACKLOG
-------
 
- [ ] Construct Previews via Transaction via URL: provide multiple inputs: var:1:action:1:action:1  or use ?x= query params
- [ ] REVIEW: can/should we support > 1 frame per page ?
 
- [ ] add one more object-factory
  - [ ] swap contract


DONE
----
- [x] build a set of object factories that compose petri-nets for users
  - [x] transfer model
  - [x] polling / votes

ICEBOX
------
- [ ] consider adding an animation mode - could use CSS animations to show transitions
- [ ] add wf-net runner - use petri-nets to design processes with preconditions
  - [ ] add corresponding state machine model to the on-chain gno code
