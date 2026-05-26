# Deferred

Items acknowledged as in scope for this project eventually, but intentionally not part of MVP. Each carries rationale so the scope decision is durable and visible over time — the drift of ideas is pedagogical content on this project, not something to sanitize.

An item lives here once we've made an **explicit decision** to exclude it from MVP. Features that might still be MVP but haven't been scoped yet live in [`requirements.md`](./requirements.md), not here. Features that are out-of-scope for the entire project (not just MVP) would get their own treatment — none yet.

Cross-ref: [`requirements.md`](./requirements.md) for MVP scope; [`tradeoffs.md`](./tradeoffs.md) for design decisions and their costs — especially §4, which explains why entries here (like those in `requirements.md`) are deliberately coarse and may have gaps.

---

- **Password reset** (carved out of [`requirements.md`](./requirements.md) item 1 — auth)
  - *What:* standard email-token flow — request → email link → reset form.
  - *Why deferred:* login + registration already exercise the full auth lifecycle; reset is additive, not foundational. Keeping MVP auth to two flows keeps the teaching surface tight.
  - *Dependencies:* email sending, which is also not in MVP.

- **Admin-addable tracks** (carved out of [`requirements.md`](./requirements.md) item 2 — library)
  - *What:* an admin panel for adding / editing / removing catalog tracks outside of the seed fixture.
  - *Why deferred:* with a 10-track seed, an admin surface is overhead with no immediate payoff. It becomes valuable when the catalog grows beyond fixture-friendly size.
  - *Dependencies:* none.

- **Library browsing / navigation**
  - *What:* UI for exploring the catalog — sortable track lists, browse-by-artist, browse-by-album, landing pages.
  - *Why deferred:* MVP renders the library as a single flat ordered list. Browsing becomes meaningful once the catalog grows or once playlists give users reasons to navigate the library by context.
  - *Dependencies:* richer catalog or playlists for full utility; can technically ship standalone.

- **Playlists**
  - *What:* user-created, user-owned, ordered groupings of tracks. The feature that distinguishes a streaming service from a local player.
  - *Why deferred:* shipping the player end-to-end first (auth → library → playback → now-playing UI) takes priority. Playlists are the first roadmap feature after MVP lands.
  - *Dependencies:* users (present via auth in MVP) and tracks (present via library in MVP) — no technical block.

- **User-uploadable music**
  - *What:* per-user track uploads — file upload, validation, metadata extraction (e.g. ID3 parsing via `mutagen`). Distinct from the admin-curated catalog.
  - *Why deferred:* big teaching surface (multipart upload, file storage, quotas, tag parsing) that deserves its own dedicated arc rather than being smuggled into MVP.
  - *Dependencies:* file-uploading; natural teaching progression from MVP.

- **Saves / likes**
  - *What:* a user's personal favorites set — tracks marked for quick access; possibly extending to albums or playlists later.
  - *Why deferred:* **playlists first.** A "liked tracks" view is functionally a system-owned playlist; the playlist model needs to exist before likes has a natural home to live in.
  - *Dependencies:* playlists.

- **Track / album artwork**
  - *What:* per-track or per-album cover images shown in library lists, now-playing display, and anywhere a track is referenced visually. Real streaming UI is visually-driven by cover art.
  - *Why deferred:* artwork is pure polish at MVP scope — no functional behavior depends on it. Adding it means sourcing art alongside each CC-licensed track (licensing per-image, not just per-audio-file), committing image assets, and deciding a fallback for artless tracks. Meaningful surface, zero payoff while the audio pipeline itself isn't working end-to-end yet.
  - *Dependencies:* none technical; blocked by source curation more than engineering.
