# r/gnoframe

## GnoFrame

GnoFrame is a framework for building Gno applications that can be embedded in other applications. It provides a specification for building Gno applications, allowing developers to create modular and reusable components that can be easily integrated into different projects.

##  Experimental Features

These features may change or be removed in future releases.

Some of these ideas are being explored and may be available in the future,
but are not yet fully implemented or stable.

- GnoFrame: a framework for building Gno applications that can be embedded in other applications
  - provides a specification for building Gno applications
- GnoMark: a markdown parser and renderer for Gno applications
  - supports custom js/HTMLElements or Gno-backed templates
  - FUTURE: integrate w/ forms when available on gno.land
- Template: a {{tag | helper}} style template engine for working with strings
    - supports custom functions and helpers
    - stores templates in on-chain registry
- Oracle: a toolkit for CQRs (Commands, Queries, and Responses) in Gno applications
- Pflow: a custom frame implementation for GnoFrame applications
    - wf-nets used for multi-step processes
    - state-machines / Petri-Nets - used to construct DSL grammars for formal specification
