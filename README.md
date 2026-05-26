# Spotify Clone

A Flask-based learning project — minimal scaffold.

## A note on style

This is a learning project. The code is written naively on purpose — we accumulate
the pain points that motivate "best practices" before reaching for those abstractions,
so the motivation is felt rather than inherited.

Example: every route lives in `app.py` until adding one more genuinely hurts.
Blueprints aren't introduced because they're the right answer in the abstract —
they're introduced when `app.py` is the obviously wrong answer. The refactor that
introduces structure is itself the teaching moment; premature structure hides what
the structure is for.

If you're reading this codebase and something looks "wrong" — that's probably
deliberate. Wait for it to hurt, then fix it.

## Getting started

```
make local-install
make local-run
```

Then visit http://localhost:5000.
