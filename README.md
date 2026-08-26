# Pointolio

A Flutter app for keeping score at game nights.

A *party* is one play session of a game.
You add rounds and points per player, and Pointolio tracks totals, standings and the winner.
Everything is stored on device, so it works with no account and no network.

iOS only.

## Why Pointolio?

I decided to build this app because I play card games with my friends and we were mostly tracking scores in the Notes app.
Yes I know there are many apps that already do this, but I wanted to build my own my way and also show you how I build things.

I hope you'll learn something from this project.
Feel free to ask questions, suggest improvements, or share ideas.

## How it started

When I started it there was one goal, create an app that will keep the scores of games we play, no sketches no ideas written.
I'm not a designer so a big thanks to AI, for helping with the design :).

At the beginning, I didn't focus much on logging or error handling, proper reusability.
The goal was to ship something as early as possible.
Over time, I plan to improve the project with proper error handling, logging, tests.

## Tech stack

| Tool | Role |
| --- | --- |
| **Flutter** | UI, Dart SDK `^3.10.3` |
| **flutter_bloc** | State management, Cubit only |
| **drift** | Reactive SQLite persistence |
| **go_router** | Routing, including the stateful tab shell |
| **get_it** | Dependency injection |
| **share_plus**, **url_launcher**, **package_info_plus** | Platform integration |
| **Swift Package Manager** | iOS native dependencies, no CocoaPods |
| **mise** | Task runner for build, checks and release |
| **fastlane** | TestFlight uploads |

Fonts are bundled as assets rather than fetched at runtime: Space Grotesk for numbers and titles, Hanken Grotesk for body text.

## Architecture

Feature-first.
Each feature under `lib/features/<feature>/` owns its data, domain and presentation layers.

```
lib/
  common/       database, DI, theme, shared widgets, error handling
  features/     create_game, home, manage, scoring, settings, sharing
  router/       go_router setup and the tab shell
```

Data flows one way:

```
Page -> Cubit -> Repository -> DAO
```

Pages read state with `BlocBuilder`/`BlocSelector` and never touch DAOs directly.
Repositories map database errors into domain results.

The app is a three tab shell over Parties, Players and Games, with full screen routes for scoring, forms and settings.

## Development

Requires the Flutter SDK, Xcode and [mise](https://mise.jdx.dev).
Run `mise trust` once after cloning.

| Task | What it does |
| --- | --- |
| `mise run deps` | Fetch packages |
| `mise run codegen` | Generate drift DAOs and other sources |
| `mise run codegen:watch` | Regenerate on change |
| `mise run analyze` | Static analysis |
| `mise run test` | Test suite |
| `mise run verify` | Analyze and test |
| `mise run prepare` | Clean, deps, codegen |
| `mise run build:ios` | Unsigned release build |
| `mise tasks` | Everything else |

Drift `.g.dart` sources are gitignored, so a fresh clone will not compile until `mise run codegen` has run.

Lint rules live in `analysis_options.yaml`.
They are strict by design and analysis is expected to stay at zero issues.

## Releases

`pubspec.yaml` is the single source of truth for both halves of the version:

```yaml
version: 2.1.0+11
```

Flutter passes these to Xcode as `FLUTTER_BUILD_NAME` and `FLUTTER_BUILD_NUMBER`, so neither is ever set in the Xcode project.

`mise run verify:release` enforces three gates against `main`:

- the semver increased, a build number bump alone is not enough
- the build number increased, since App Store Connect rejects one it has already seen
- `CHANGELOG.md` has a `## [x.y.z]` entry with content

`mise run release` chains the whole pipeline and ends in fastlane.
There is a `release` agent under `.claude/agents/` that drives it.

## Screenshot generation

App Store screenshots come from an integration test harness that drives the real app against a seeded in-memory database, so every shot matches production.

The harness lives in `screenshots/`:

- `screenshot_test.dart` navigates the app and captures each screen.
- `screenshot_seed_data.dart` holds deterministic players, games and parties.
- `driver.dart` writes the captured PNGs to disk.

Boot a simulator, then run:

```bash
flutter drive \
  --driver=screenshots/driver.dart \
  --target=screenshots/screenshot_test.dart \
  -d <deviceId>
```

Output lands in `screenshots/output/output-ios/` at the simulator's native resolution, so pick a device whose size matches the App Store slot you need.

| File | Screen |
| --- | --- |
| `01_parties.png` | Parties home (active and completed) |
| `02_scoring_table.png` | Scoring, round by round table |
| `03_standings.png` | Scoring, standings and winner |
| `04_share.png` | Share result card |
| `05_new_party.png` | New party form |
| `06_players.png` | Players tab |
| `07_games.png` | Games tab |
