# Requirements

MVP scope — settled. Explicit deferrals live in [`deferred.md`](./deferred.md). Kept at feature-level granularity by design — see [`tradeoffs.md`](./tradeoffs.md) §4 for why. Future edits here capture implementation findings, not scope drift; new features go through the scoping process again before being added.

1. **Authentication** — user login, registration, and logout.
   - **Access model:** all application views require an authenticated session. Unauthenticated requests redirect to the login page. Post-login lands on the library view (item 2 — the only non-auth surface in MVP). Logout ends the session and returns to the login page.
   - **Why auth-gated at all in MVP:** all personalization features that would make login user-visibly useful (playlists, likes, uploads) are in [`deferred.md`](./deferred.md). Auth in MVP exists for teaching value — the full login/register/logout lifecycle — with no user-facing personalization yet attached. When playlists land post-MVP, the auth already being in place pays off.

2. **Audio library** — curated seed catalog of ~10 CC-licensed / public-domain tracks committed directly to the repo, with artist / album / track metadata. Initial source: Free Music Archive.
   - **Audio format:** MP3 only. Universal browser `<audio>` support, well-understood encoding, no codec-picking conversation to have. Other formats (OGG, FLAC, etc.) are out of scope for MVP — if a source track isn't MP3, transcode during the curation step rather than teaching the browser-support matrix.

3. **Playback controls** — split into user-gesture *events*, persistent *modes*, and *display elements*.

   **Events** (user-initiated; immediate; unaffected by mode state):
   - **play** — start playback of the selected track.
   - **pause** — halt playback in place; track stays loaded; resumable from the same position.
   - **stop** — halt playback and fully unload the track; clears "now playing"; not resumable.
   - **skip-next** — stop current track, play the next track in library order.
   - **skip-previous** — stop current track, play the previous track in library order.
   - **seek / scrub** — jump to a specific position within the current track.
   - **volume** — adjust playback volume; persists across tracks within a session.
   - **Skip always wraps**, regardless of loop mode:
     - skip-next past the last track → first track.
     - skip-prev past the first track → last track.

   **Autoplay:** always on; not a user-toggleable mode. Natural end-of-track always triggers a transition — the system never simply halts at a track's natural end.

   **Modes** (persistent toggles; govern track-selection semantics):

   - **loop** — three states: **off**, **loop-all**, **loop-single**. Governs what "transition at natural end-of-track" means:

     | loop | natural end-of-track |
     |---|---|
     | off | advance to next; stop at end of list |
     | all | advance to next; wrap at end of list |
     | single | restart current track |

     - In **loop-single**: skip still moves to the adjacent track; loop-single mode persists and applies to whatever is now the current track.

   - **shuffle** — on/off. When on, track selection (for autoplay transitions, skip-next, and skip-prev) picks a random track from the library instead of by library order. When off, default sequential order applies.
     - **Random is infinite.** Same track can be chosen again; there's no "shuffled-once-through" semantic, no play history.
     - **Shuffle dominates loop.** While shuffle is on, loop mode is effectively a no-op — every end-of-track event just picks a fresh random track, and the "end of list" concept that loop governs never arises. Accepted simplification; loop becomes meaningful again only when shuffle is turned off.
     - skip-prev under shuffle picks a new random track, same as skip-next — no backtracking through history.

   **Display elements** (visible during playback):
   - **Now-playing display** — currently-playing track metadata: artist, album, track name. The visual anchor for "what is audible right now."
   - **Track progress indicator** — visual representation of current position within the track; updates in real time; user-interactive via **seek**.
     - `[Open]` Numeric position / duration text alongside the bar (e.g. `1:14 / 3:47`) — not decided. Seek works off the bar alone, so this is polish, not functional. Defer the call until the bar is implemented and we can see whether its absence feels wrong.

   - Ordering context: the audio library is itself a single ordered list — skip-next / skip-previous traverse that list. No separate queue or playlist concept in MVP.
   - Cross-ref: [`tradeoffs.md`](./tradeoffs.md) §2 — controls on the `<audio>` element are trivial in isolation, but persisting playback state across page navigation is the load-bearing design problem. MVP accepts the gap (playback stops on navigation); §2 captures the staged progression toward a fix.

4. **Search** — simple text filter over the library.
   - *What:* a text input on the library view that, as the user types, narrows the visible track list to entries matching the query.
   - *Implementation:* client-side vanilla JS filtering over the already-rendered list. No server round-trip.
   - *Why this shape:* the catalog is ~10 tracks, which makes a client-side filter trivially fast and avoids the surface area of server-side search (URL state, form submission, pagination, etc.). Also provides a small, scoped exposure to vanilla JS and DOM manipulation for the mentee without pulling in a JS framework.
   - *Filter target:* track name + artist + album — a track entry matches if the query substring appears in any of the three fields.
   - *Filter semantics:* case-insensitive substring match.
   - *Empty state:* when the query matches zero tracks, the library view renders a short "no tracks match" message in place of the list. Basic — a single line of text, no suggested-queries, no "clear search" button beyond whatever the input itself offers.
   - *Future:* server-side search becomes relevant once the catalog grows past a client-side-filter-friendly size, or once search has to span beyond the currently-rendered page.
