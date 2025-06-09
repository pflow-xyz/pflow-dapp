# Petri Net Labeling Grammar Overview

This document describes the formal grammar for naming elements in a Petri net used to model a single-choice voting system. The grammar governs **label construction** for places and transitions in a way that is both human-readable and programmatically parsable.

---

## 🎯 Purpose

To define a consistent and extensible **naming convention** for:
- **Places**: Representing resources, states, or choices
- **Transitions**: Representing vote-casting actions

---

## 📘 Grammar (EBNF)

```ebnf
Label           ::= TransitionLabel | PlaceLabel

TransitionLabel ::= ActionPrefix "_" ChoiceName

PlaceLabel      ::= "voteOnce" | ChoiceName

ActionPrefix    ::= "VOTE" | "CAST" | "SEND"  (* Extensible verb roots *)

ChoiceName      ::= "choice" Digit+

Digit           ::= "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"
```

---

## ✅ Examples

| Label            | Type           | Description                              |
|------------------|----------------|------------------------------------------|
| `VOTE_choice1`   | Transition     | Action to vote for choice 1              |
| `CAST_choice2`   | Transition     | Alternative action verb ("cast")         |
| `choice3`        | Place          | Final state for choice 3                 |
| `voteOnce`       | Place (special)| Token-limited eligibility to vote        |

---

## 🧱 Extensibility

The grammar can be expanded to support more complex expressions:

### Named Choices
```ebnf
ChoiceName ::= Identifier
Identifier ::= Letter (Letter | Digit | "_")*
Letter     ::= "a"…"z" | "A"…"Z"
```

Examples:
- `VOTE_yes`
- `VOTE_rejectOption`
- `choice_final`

### Conditional or Guarded Transitions
```ebnf
TransitionLabel ::= ActionPrefix ["_IF_" Condition] "_" ChoiceName
Condition       ::= Identifier
```

Example:
- `VOTE_IF_ELIGIBLE_choice2`

### Namespacing for Multi-Round or Multi-Stage Systems
```ebnf
TransitionLabel ::= RoundPrefix "_" ActionPrefix "_" ChoiceName
RoundPrefix     ::= "ROUND" Digit+
```

Example:
- `ROUND2_VOTE_choice1` → vote in round 2

---

## 🧠 Summary

This labeling grammar helps unify Petri net construction and visualization by:
- Making semantics explicit in names
- Enabling automation (e.g., parsing, validation)
- Supporting programmatic model generation
