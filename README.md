# dotCMS iOS Demo

A native SwiftUI app that consumes content from a dotCMS instance over GraphQL.
It is the mobile counterpart to the dotCMS Next.js example, built to be shown
live to partners and prospects.

## Setup

### 1. Configure the instance

```bash
cp Config.example.plist Config.plist   # Config.plist is gitignored
```

Fill in `DOTCMS_HOST`, `DOTCMS_SITE_ID`, `DOTCMS_SITE_NAME`. Current values
target the local instance and the `bank.com` site:

| Key | Value |
|---|---|
| `DOTCMS_HOST` | `http://localhost:8082` |
| `DOTCMS_SITE_ID` | `4afebb3f5a60baed95fa8e55e1038087` |
| `DOTCMS_SITE_NAME` | `bank.com` |

### 2. Provide the API token

**The token never goes in a file.** It is read from the Keychain, seeded on
first launch from a scheme environment variable.

Generate a read-only key in the admin under **System > Users > admin > API
Access Tokens**, scoped to Pages, Folders, Assets and Content. Then pick one:

**Option A — run from the terminal (simplest):**

```bash
export DOTCMS_AUTH_TOKEN='...'
./Scripts/run-simulator.sh
```

The token is seeded into the simulator Keychain on first launch, so later runs
from Xcode work without it.

**Option B — run from Xcode:** the scheme passes `$(DOTCMS_AUTH_TOKEN)` through
from the environment Xcode itself was launched with. Launching Xcode from Finder
does **not** inherit your shell exports, so either launch it from a shell that
exports the variable:

```bash
export DOTCMS_AUTH_TOKEN='...' && open DotCMSDemo.xcodeproj
```

…or set the value directly in **Product > Scheme > Edit Scheme > Run >
Arguments > Environment Variables**. The scheme file is tracked, so do not
commit a literal token into it.

> If the app shows **"Not configured: no API token"**, the scheme has no token
> in its environment. That is the single most common setup problem.

> A token compiled into an app binary is trivially extractable from the IPA.
> It is never hardcoded here, and requests to do so "just for the demo" should
> be refused.

### 3. Build

```bash
python3 Scripts/generate-project.py    # regenerate the Xcode project
open DotCMSDemo.xcodeproj
```

Apollo is pulled via SPM automatically. Requires Xcode 16+, iOS 17 minimum.

## Schema handling

The GraphQL schema is **committed** at `Schema/schema.graphqls` and all models
are generated from that file, never from the live endpoint at build time.

```bash
# Regenerate models after a schema change
./Scripts/bootstrap-codegen.sh

# Detect a content type changing under the app — run before any demo
DOTCMS_AUTH_TOKEN=... ./Scripts/check-schema-drift.sh
```

`check-schema-drift.sh` re-downloads the live schema, diffs it against the
committed copy, prints the diff and exits non-zero on any difference. This is
what tells you a content type changed *before* a partner call does.

Because operations live in `.graphql` files and are validated at build time,
querying a field that no longer exists fails codegen with a file and line
number rather than becoming a blank screen at runtime.

## Pointing at a different instance

1. Update `Config.plist` with the new host and site identifier.
2. Re-download the schema: `Scripts/download-schema.sh`
3. Re-run codegen: `./Scripts/bootstrap-codegen.sh`
4. Fix any compile errors the new schema surfaces. **Expect some** — dotCMS
   derives GraphQL names from each content type's *variable name*, and these
   differ between instances.

## Adding a content type to the registry

1. Add a fragment at `GraphQL/Fragments/<Type>Fields.graphql`. One fragment per
   content type; screens compose fragments and never select fields directly.
2. Add a query under `GraphQL/Operations/` if the type needs its own screen.
3. Run `./Scripts/bootstrap-codegen.sh`.
4. Add a SwiftUI view and register it in the component registry by content
   type variable name.

Unknown content types render a visible "No component for type X" placeholder
rather than being skipped silently.

## Screens

| Tab | Source | Notes |
|---|---|---|
| Home | Page API `/index` | Layout + component registry |
| Blog | `BlogCollection` | Listing, then detail by `urlTitle` |
| About | Page API `/about-us/index` | Same `PageScreen` as Home, different URI |
| Settings | — | Instance, cache TTL, registry, schema hash |

Home and About are the *same view*: `PageScreen(uri:fallbackTitle:)`. Adding
another page asset to the app is one line, with no new rendering code.

## Tests

```bash
./Tests/run-tests.sh
```

No Xcode needed — `swiftc` only. Covers the two failure modes that actually
bit during development:

- **StoryBlock parsing** against a real captured body, in both the plain and
  Apollo `AnyHashable`-wrapped shapes. Guards the bug where Apollo's default
  `typealias JSON = String` made blog detail fail with `couldNotConvert`.
- **Nullability degradation**: a contentlet with every field stripped must
  still yield a non-empty title, a stable `id` (a fresh `UUID()` would break
  SwiftUI `ForEach` diffing), and no divide-by-zero on image aspect ratios.

## Architecture notes

- **All content fields are optional** in the app layer, even where the schema
  declares non-null. Views render a placeholder or omit the row. `Blog.urlTitle`
  is `String!` today and could still be deleted by an author tomorrow.
- **Caching** uses dotCMS's server-side query cache via the `dotcachettl`
  header, injected by an Apollo interceptor. `.demo` (1s) is the default so
  content edits appear on the next pull-to-refresh; `.production` (300s) shows
  the performance story. Toggle in Settings.
- **Images** are always requested resized. The raw demo assets are up to
  5184x3456 / 2.2 MB; `/dA/{id}/image/{width}w/{quality}q` returns ~18 KB WebP.
- **Unknown content types and unknown StoryBlock nodes both render visible,
  labelled placeholders** rather than being skipped. The About Us page contains
  a `gridBlock` node the app does not implement, so that placeholder is
  demonstrable on real content.
- **`sortBy` fails silently.** dotCMS returns zero results with no error when
  `sortBy` names a field the index cannot sort — `Blog.modDate` does this while
  `Blog.publishDate` works. The blog listing falls back to an unsorted query and
  sorts client-side, so a demo degrades to unordered posts, never a blank list.

## Trade-off: no backend-for-frontend

**This app talks to dotCMS directly.** For a real product there should be a
backend-for-frontend in front of dotCMS, because:

- The API token would stay server-side rather than shipping inside the app.
  Keychain storage protects it at rest on device, but the token still reaches
  the client and can be extracted from a jailbroken device or a proxied session.
- Queries could be changed server-side without an App Store review cycle.
  Today, a content model change that needs a query change requires a new build
  and a release.
- Response shaping, field whitelisting and rate limiting would live in one
  place instead of in the client.

This is a deliberate demo-scope decision, not an oversight. Raise it before a
partner does.

## Out of scope

UVE / visual editing (the Universal Visual Editor cannot render a native app —
no iframe, no DOM), authentication, offline sync, push notifications, deep
links, analytics, and any write operation against dotCMS.
