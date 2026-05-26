# Tradeoffs

This project is a teaching vehicle, so technical decisions are weighed against **what the learner has to absorb to understand them**, not only against the usual engineering criteria. That bias should be explicit in every entry below.

Each entry records:
- **Decision** — what we picked.
- **Rejected** — what we didn't pick, and why not.
- **Costs we accept** — what this decision makes harder or impossible.
- **Mitigations** — what we can do later if a cost becomes painful.

---

## 1. Frontend — Django templates, no JS framework

**Decision:** Server-rendered Django templates. No Next.js, no React, no build pipeline.

**Rejected:** Next.js (and by extension any SPA framework).

**Why:** The learner's current toolkit is Python only. A Next.js frontend would stack four parallel learning curves on top of Django: JavaScript the language, React's component/state model, Next.js routing and rendering modes, and a Node build toolchain. Each of those is a multi-week unit on its own. Keeping the frontend in Python-flavored templates lets every new concept in the project be introduced against a base the learner already has, instead of against four new ones.

**Costs we accept:**
- **No client-side state.** Every navigation is a full page reload. Any in-progress client state — most notably audio playback — is destroyed on navigation. See Tradeoff 2.
- **No partial updates.** Adding a song to a playlist, liking a track, etc. will re-render the whole page rather than swapping a fragment. For a small clone this is fine; it will feel dated compared to real Spotify.
- **Reduced resume signal.** "Django templates" is a less marketable line on a portfolio than "Django + React." This is a real cost, not a made-up one — we are choosing pedagogy over signaling.

**Mitigations (only if a cost becomes load-bearing):**
- Introduce **HTMX** for partial page swaps. Adds one new concept (hx-* attributes) rather than a whole new language.
- ~~Introduce vanilla JS narrowly, one feature at a time, when a specific requirement genuinely cannot be met server-side.~~ — promoted to first-class MVP commitment; see §3. Left struck-through here so the evolution from "deferred mitigation" to "baseline stack" is visible.

---

## 2. Audio playback across navigation

**Context:** A Spotify clone's core UX is "music keeps playing while I browse." Because of Tradeoff 1, every page navigation is a full reload, which destroys the `<audio>` element and stops playback. This is a direct consequence of the stack choice, not an independent problem.

**Decision:** **MVP ships option 1 (accept the gap).** The full arc for this problem is a staged progression through four solutions, each motivated by the pain of the previous — the progression itself is the lesson, not just the final state.

Options, in ascending order of complexity:

1. **Accept the limitation.** Playback stops on navigation. The clone is honest about being a clone. The mentee learns *why* SPAs exist by feeling the exact pain they solve — a real pedagogical win, not a cope.
2. **Sticky player with vanilla JS + `localStorage`.** A small `<audio>` element in the base template persists playback position in `localStorage` and resumes on next page load. Teaches one concept (client-side persistence) in isolation. Still has a brief audible gap during navigation.
3. **HTMX partial swaps.** Only the main content area re-renders on navigation; the player stays mounted and playback is unbroken. Closest to real Spotify UX without adopting a full SPA framework. Adds HTMX to the learner's plate and changes how every page is structured.
4. **SPA framework (React / Next.js / equivalent).** The proper solution to the underlying problem — client-side routing, no full reloads, player just stays mounted. End state of the arc, not a near-term option.

**Planned progression:** 1 → 2 → 3 → 4. Each step is driven by the mentee feeling the specific pain the next step solves, not by a calendar. No step is committed until the previous one is lived with long enough for the limitation to register.

- **1 → 2** when "playback stops on every nav" becomes the thing the mentee notices every session. Teaches: AJAX exists because round-tripping through the server for small state changes is painful; client-side persistence as the first mitigation.
- **2 → 3** when the audible gap during navigation becomes the irritant, or when a second feature wants partial-update behavior. Teaches: HTML-over-the-wire partial swaps, why SPAs exist, without yet paying the full SPA cost.
- **3 → 4** *way* future. The jump only makes sense once the mentee has JS/DOM fluency from the vanilla-JS and HTMX stages, and a specific requirement (real-time collaborative UI, rich interactive surfaces) genuinely exceeds what HTMX can cleanly express. Walks back Tradeoff §1 entirely — at which point the original stack choice has outlived its pedagogical purpose, and the mentee has the groundwork to take on the stack it was protecting them from.

**Why this shape (vs. picking the "best" option now):** Each option teaches a concept the next option builds on. Jumping straight to option 3 or 4 would skip the motivating pain that makes "why does this even exist" legible. The drift of solutions — same as the vanilla-JS drift in §3 and the SQLite drift in §5 — is pedagogical content, not noise to sanitize.

**Costs we accept:**
- **MVP ships with a known-broken UX.** Playback stops on every navigation. For a user this would be unacceptable; for a teaching vehicle with an audience of one learner and one instructor it's a feature.
- **Progression is fuzzy.** No hard trigger for when to move from step to step — relies on Nick's read of mentee readiness. Risk: sitting on a stage too long (boredom) or advancing too fast (skipping the motivating pain).

**Mitigations:**
- Each transition is its own scoping conversation — don't pre-commit the shape of steps 2, 3, or 4 now. Each stage's details get decided against what the codebase actually looks like when the transition arrives.
- If the mentee's pain signal is unclear, let them try to articulate the problem before offering the next step — the articulation itself is the lesson.

---

## 3. Vanilla JavaScript in MVP

**Decision:** Vanilla JavaScript is part of the MVP stack — a first-class ingredient, not a deferred mitigation.

**Rejected:** Templates-only (pure server-rendered, zero JS), which was the implicit framing under §1.

**Why:** Several MVP requirements (`requirements.md` item 3 — progress indicator, seek, volume; item 4 — client-side search filter) are not reasonably implementable server-side. Progress indicator needs real-time updates. Seek/volume need instant feedback on user gesture. Client-side search was explicitly chosen over server-side search to avoid form-submit round-trips on a ~10-track catalog. Together, these make JS unavoidable at MVP scope. Better to state the commitment plainly than to keep treating JS as a "possible future mitigation" while silently baking it into MVP features.

**Costs we accept:**
- The mentee (Python-only background) has to learn some JavaScript — however minimal. The original stack choice under §1 was partly motivated by keeping them in Python; this walks that back. Blast radius is capped by sticking to **vanilla JS, no frameworks, introduced one feature at a time** — not as a monolithic "now you learn JS" phase.
- JS adds a second language to the maintenance surface — two syntaxes, two mental models, two debugging contexts. Some small amount of cognitive overhead on every feature that spans both.

**Mitigations (only if a cost becomes load-bearing):**
- Keep JS scope narrow and local to each feature. No shared JS architecture ahead of need.
- Where a feature can be implemented server-side cleanly (e.g. future playlist CRUD), prefer the server-side version even if JS would be slightly more polished.

---

## 4. Incomplete / coarse scoping as a deliberate choice

**Decision:** `requirements.md` and `deferred.md` are maintained at feature-level granularity — feature name, rough behavior, rationale. They are not broken down into per-feature user stories, formal acceptance criteria, task decompositions, sprint plans, or pre-specified data models. Detail is added only where behavioral semantics are genuinely load-bearing and non-obvious (e.g. playback's event/mode/autoplay/loop/shuffle interaction); where the shape is familiar (auth, basic search), the entry stays short.

**Rejected:** Fine-grained upfront scoping — full user-story inventory, acceptance criteria per feature, task breakdown, pre-specified data-model diagrams, etc.

**Why:** Fine-grained scoping before the code exists tends to encode premature decisions that haven't been pressure-tested by implementation. It also creates a false sense of certainty that actively discourages productive mid-implementation drift — which on this project is a pedagogical *feature*, not a *bug* (see §3 for an example: vanilla JS drifted from "deferred mitigation" in §1 to "MVP commitment" as requirements clarified). Drilling down uniformly would hide that drift under a veneer of planned-all-along.

**Costs we accept:**
- **Ambiguity during implementation.** Decisions not pre-answered will be made on the fly. Risk: a locally-sensible call that conflicts with a separate call elsewhere.
- **Missing pieces surface late.** Writing acceptance criteria often exposes edge cases that coarse scoping hides. Without that forcing function, some edges only turn up in use.
- **Harder to delegate or parallelize.** Fine-grained scoping is what makes independent contribution possible. Solo implementation makes this cost latent, but it's real if the project ever opens up.

**Mitigations:**
- Drill down only where semantics are load-bearing — invest scoping effort asymmetrically, not uniformly.
- Use `[Open]` markers during discovery to flag ambiguity explicitly rather than paper over it.
- Capture drift in the docs as it happens (`tradeoffs.md` evolution, struck-through lines, ongoing `requirements.md` edits) rather than silently overwriting past state.

---

## 5. Database — SQLite for MVP, Postgres deferred

**Decision:** SQLite as the MVP database engine. Django's default, file-based, zero setup.

**Rejected:** Postgres for MVP — the originally chosen DB earlier in the project. Not rejected permanently; deferred until MVP scope demands justify the setup cost.

**Why:** Postgres requires the mentee to operate a database service — via Docker (assumes Docker comfort we haven't verified), native install (OS-specific setup friction), or hosted cloud (introduces credentials and network dependency). None of those earn their keep at MVP scope: ~10 tracks, basic auth, no concurrent writes, and nothing in `requirements.md` reaches for Postgres-specific features. SQLite is Django's default, which makes diverging an opinionated choice requiring a reason — one we don't have for MVP.

**Costs we accept:**
- **Weaker concurrency.** SQLite serializes writes. Fine for a single-dev local setup; not a production-realistic story.
- **Weaker type enforcement.** SQLite's type affinity is looser than Postgres's strict typing; some ORM operations behave slightly differently at the edges.
- **No Postgres-specific features.** `JSONField` stores as text with weaker query semantics; no native full-text search; no array type. If features later need these, the Postgres-swap timeline moves up.
- **Production signaling.** Shipping a Django app with SQLite is considered beginner-flavored; Postgres is the production default. Same-shaped tradeoff as §1's portfolio-signaling cost.

**Mitigations:**
- Stick to DB-agnostic ORM operations; avoid accidentally depending on SQLite-specific or Postgres-specific behavior, so the eventual swap stays cheap.
- The swap trigger is well-defined — when concurrent writes, full-text search, or a real production deploy becomes the goal, move to Postgres. Until then, SQLite's zero-friction payoff dominates.

**Related:** same drift shape as §3 (vanilla JS) — an earlier stack pick that walks back under closer inspection of MVP cost/benefit. Second instance of that pattern is itself meaningful: worth being more skeptical of "stack defaults" going forward until vetted against mentee setup cost.

---

## 6. Styling — vanilla CSS, no framework

**Decision:** Hand-written CSS. No framework, no utility-class system, no preprocessor.

**Rejected:** Tailwind (explicitly); Bootstrap and other component-class frameworks by extension.

**Why:** Vanilla CSS teaches the mentee what the browser actually does — selectors, the cascade, the box model, specificity — against nothing but the platform itself. A framework replaces most of that surface with its own idioms; Tailwind specifically substitutes a utility-class vocabulary for the cascade, which hides the exact model the mentee needs to build first. Nick also has a standing preference against Tailwind, which is worth naming as a real input to the decision — aesthetic/ergonomic fit of the instructor to the tool matters on a teaching project, because the instructor is the one modeling it.

**Costs we accept:**
- **Slower to "look decent."** A framework would give the clone a reasonable baseline appearance in an afternoon. Vanilla CSS looks raw until deliberately styled.
- **No built-in design system.** Spacing, color, typography choices are made fresh each time rather than inherited from a framework's defaults. More decisions, more inconsistency risk, more opportunity to teach *why* design systems exist once the pain is felt.
- **Portfolio signaling.** Same shape as §1 and §5 — "vanilla CSS" reads less modern than "Tailwind" on a resume. Same trade as the other stack calls: pedagogy over signaling.

**Mitigations:**
- A later swap to Tailwind (or another framework) is on the table if the mentee's CSS baseline is solid and the clone's visual polish becomes a goal. Not a commitment — Nick's preference is a real counterweight — but the swap is structurally available once the fundamentals are in place.
- Keep the CSS surface small. No premature abstractions (custom properties, BEM, utility layers) ahead of need — the point is to feel the raw cascade, not to build a mini-framework from scratch.

**Related:** third instance now of "start with the platform / default, graduate to a tool later when the pain is specific" — see §3 (vanilla JS before HTMX before SPA framework, per §2) and §5 (SQLite before Postgres). Explicit pattern on this project, worth leaning into rather than re-deriving each time.

---

## 7. App split — `accounts` / `library` / `player`

**Decision:** Three Django apps, partitioned by bounded domain:

- **`accounts/`** — authentication and user identity. Login, registration, logout, session, user model (if we extend Django's default).
- **`library/`** — catalog domain. Track / artist / album models, the seed fixture loading, the library list view, search filter wiring.
- **`player/`** — playback domain. Now-playing state, playback UI, progress indicator, seek / volume / loop / shuffle views, and the JS that drives the `<audio>` element.

**Rejected:**
- **Single monolithic app** (e.g. one `core/` or `spotify/` app holding everything). Simpler file tree, zero cross-app imports — but every feature lives in the same namespace, and the mentee never sees the Django app boundary as a real tool for thinking about feature domains. The boundary is most of what Django's "app" concept *is*; hiding it defeats the teaching purpose.
- **Finer-grained split** (e.g. `playback/` separate from `player_ui/`, `tracks/` separate from `search/`, etc.). Every additional boundary is more cross-app wiring to read and understand. At MVP scope — ~10 tracks, single playback context, one search — the extra seams earn nothing and add cognitive overhead.

**Why this split specifically:**
- Each app maps to a noun the mentee can name before opening the code: "where users live," "where the catalog lives," "where playback lives." That mapping is the entire point of the exercise.
- The three slices match the three main [`requirements.md`](./requirements.md) feature groups (auth → accounts, library + search → library, playback controls → player). Doc and code structure mirror each other, which cuts one layer of translation for the learner.
- Each app has its own models, views, URLs, templates, and static — the standard Django app shape. Nothing exotic, nothing bespoke. The app boundary itself is the lesson; the contents of each are conventional.

**Costs we accept:**
- **Cross-app references.** `player/` will need to import from `library/` (current track, metadata). `library/` views will need the `accounts/` auth decorators. Cross-app import chains are the tradeoff for meaningful boundaries — they're also the thing that forces the mentee to learn how Django apps import from each other, which is itself valuable.
- **Slight over-structure for MVP size.** Three apps for ~5 models total is arguably heavy. Fine — the structure is sized for what the project is *teaching about*, not for its current line count.
- **Boundary ambiguity at the edges.** Does the search filter JS live in `library/` (where the catalog is) or `player/` (where the rendered list is)? Does the now-playing display template belong to `player/` (playback) or to the base layout (site chrome)? These calls will be made as they come up; the boundary is a scaffolding, not a contract.

**Mitigations:**
- When a boundary call is unclear, make the call inline, note the reasoning in a commit message, and move on. Don't pre-solve edge cases before they exist.
- If a cross-app coupling pattern shows up repeatedly (e.g. `player/` repeatedly reaching into `library/` internals), that's a signal to reconsider the boundary — but only after the pattern is real, not hypothetical.

---

## Template for future entries

```
## N. <short title>

**Decision:** <what we picked>

**Rejected:** <what we didn't pick>

**Why:** <reasoning, with the pedagogy weight made explicit>

**Costs we accept:** <concrete list>

**Mitigations:** <what we'd reach for if a cost becomes load-bearing>
```
