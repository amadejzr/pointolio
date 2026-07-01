# Pointolio

Flutter app for keeping score at game nights.
A "party" is one play session of a game; you add rounds and points per player and the app tracks totals and winners.

## Tech stack

- **State**: `flutter_bloc` (Cubit only, no Bloc).
- **DI**: `get_it` via `locator` in `lib/common/di/locator.dart`. Everything is registered there.
- **DB**: `drift` (SQLite). Tables in `lib/common/data/tables`, DAOs in `lib/common/data/dao`, generated `*.g.dart` files are committed.
- **Routing**: `go_router` (see below).
- **Prefs**: `shared_preferences`.

## Architecture

Feature-first. Each feature under `lib/features/<feature>/`:

```
data/           repositories (talk to DAOs, map to domain)
domain/         models (only where a feature needs its own)
presentation/
  <feature>_page.dart
  cubit/        <feature>_cubit.dart + <feature>_state.dart
  widgets/      feature-local widgets
```

Shared code lives in `lib/common/`:

```
data/           database, tables, daos
di/             locator.dart (get_it)
theme/          app_theme.dart (legacy) + pointolio_theme + pointolio_tokens (new)
ui/tokens/      spacing.dart (Spacing.*)
ui/widgets/     shared widgets (SearchScaffold, ConfirmDialog, bottom sheets, etc.)
exception/      DomainException + exception mapper
result/         ActionResult (success/error + showToast)
```

Data flow is always **Page -> Cubit -> Repository -> DAO**.
Pages read state with `BlocBuilder`/`BlocSelector`, call cubit methods, and never touch DAOs directly.
Repositories return domain results and map DB errors through the exception mapper.

## Routing (go_router)

Single source of truth: `lib/router/app_router.dart` -> `createAppRouter()`.
`MyApp` in `lib/main.dart` uses `MaterialApp.router`.

- Onboarding gating is a `redirect` reading `OnboardingRepository.isOnboardingCompleted`.
- **Shell** (`StatefulShellRoute.indexedStack`) with a floating bottom navbar, hosted by `lib/router/home_shell.dart` (`HomeShell`). Three branches, each with its own navigator key so tab state is preserved:
  - `/` Parties (home) - `HomePage`
  - `/players` Players - `PlayersManagementPage`
  - `/games` Games - `GameTypesManagementPage`
- The navbar has an inline `+` that pushes `/create-game`.
- **Full-screen routes** (above the shell, no navbar): `/onboarding`, `/create-game`, `/scoring/:gameId`, `/settings`.

Navigate with `context.push` / `context.go` / `context.pop`.
Use the path helpers on `AppRouter` (`AppRouter.parties`, `AppRouter.scoringPath(id)`, etc.), never hardcode path strings.
`Navigator.pop(context, value)` is still fine inside dialogs and bottom sheets - go_router only owns page-level navigation.

The old `Navigator` + `onGenerateRoute` flow and the `Manage` page are gone.
Players and Games are now top-level tabs; Settings (`/settings`, theme only for now) opens from the gear icon on the Parties app bar.

## Theming - IMPORTANT, read before touching UI

We are mid-migration between two theme systems. **Both are live at once.**

### Legacy theme (existing screens)

`lib/common/theme/app_theme.dart` -> `AppTheme.light` / `AppTheme.dark`.
Rubik font, blue/cyan `ColorScheme`, full component themes (AppBar, Card, Input, Button, FAB, etc.).
Existing screens read `Theme.of(context).colorScheme`.
Note: this `ColorScheme` is hand-built - roles like `secondaryContainer` / `surfaceContainerHigh` are NOT defined and fall back to Material defaults (off-brand). Only use the defined roles: `primary`, `onPrimary`, `secondary`, `surface`, `onSurface`, `surfaceContainerHighest`, `outline`, `error`, `shadow`.

### New theme - "Notebook / Slate" (all new / redesigned screens)

Design system: `PointolioTheme` (a `ThemeExtension`) + tokens.
Registered as an extension on the existing `ThemeData`, so it coexists with the legacy theme.
Grab it anywhere with `context.pt`.

```dart
final pt = context.pt;                 // PointolioTheme
color: pt.surface                      // never Color(0xFF...)
style: PT.cardTitle(pt.text)           // type ramp; colour comes from the theme
color: pt.playerColor(index)           // per-person hue
boxShadow: pt.shadowFloat              // themed shadows
borderRadius: BorderRadius.circular(R.lg)
padding: EdgeInsets.all(S.md)
duration: Motion.base, curve: Motion.ease
```

Tokens live in `pointolio_tokens.dart`: `R` (radius), `S` (spacing), `Motion` (durations/curve), `PT` (type ramp).
Fonts: **Space Grotesk** for numbers/titles, **Hanken Grotesk** for body/UI, loaded via `google_fonts` (no asset files).

Rules for new work:
- New and redesigned screens use `context.pt` + `PT` + `R`/`S`/`Motion` exclusively. No hardcoded colours, no legacy `colorScheme`.
- Do not restyle existing screens unless the task is explicitly to migrate them.
- Do not delete `app_theme.dart` or rip out `colorScheme` usage - unmigrated screens still depend on it.

### Reference design

`/homepage/` (project root, NOT compiled - outside `lib/`, excluded from analysis) is the full Notebook/Slate reference module: `home_app_bar.dart`, `party_card.dart`, `floating_bottom_bar.dart`, `notebook_background.dart`, `motion.dart` (`AnimatedEntrance`, `Pressable`), plus sample pages.
Use it as the visual/interaction spec when redesigning a screen; adapt it to the real cubits/models rather than copying wholesale.

### Shared new-theme primitives (already ported into `lib/`, reuse these)

- `lib/common/ui/widgets/notebook_background.dart` - `NotebookBackground` (ruled-paper `CustomPaint`). Put it in a `Stack` behind a screen.
- `lib/common/ui/widgets/motion.dart` - `Pressable` (tap-scale, supports `onLongPress`) and `AnimatedEntrance` (staggered fade+rise; respects reduce-motion). Use `Pressable` instead of Material ink on new screens.
  - **Accessibility**: `Pressable` takes `semanticLabel`, `semanticHint`, `isButton`, `selected`, `excludeChildSemantics`. When labelled it emits one clean semantics node (gesture excluded, tap advertised on the `Semantics`). For icon-only controls set `isButton: true` + `semanticLabel` + `excludeChildSemantics: true`. For a card that contains its own nested button (like `PartyCard` + its `⋯`), label the outer `Pressable` but wrap the *decorative* sub-parts in `ExcludeSemantics` (not the whole child) so the nested button stays focusable. Mark titles/empty-state headings with `Semantics(header: true)`. The Parties screen is the reference for this; there's a semantics widget test at `test/features/home/presentation/widgets/party_card_test.dart`.
- The floating navbar (`lib/router/home_shell.dart`) is a frosted (`BackdropFilter`) pill floating over the content as a `Positioned` overlay in the shell `Stack`. The `NotebookBackground` also lives at the shell level and spans the whole screen (behind all three tabs and behind the bar). The shell injects extra bottom padding into the page subtree via `MediaQuery` (`+ kFloatingNavBarHeight + S.sm`) so page content and FABs clear the bar - new pages should read `MediaQuery.paddingOf(context).bottom` for their list bottom padding rather than hardcoding it. Because the background is shell-level, migrated pages use a **transparent** `Scaffold` (no own background). Legacy Players/Games keep their opaque `SearchScaffold` (they cover the notebook until migrated) but already get the injected bottom padding + FAB lift.

## Migration plan (order)

1. **Parties screen** (home) - new app bar, `PartyCard`, notebook background, themed empty/error/loading + edit mode. DONE.
2. Players screen (`/players`, `PlayersManagementPage`) - still legacy `SearchScaffold`. NEXT.
3. Games screen (`/games`, `GameTypesManagementPage`) - still legacy `SearchScaffold`.
4. Create-game, scoring, settings.

The Parties screen is the reference implementation for the pattern: Scaffold(`backgroundColor: pt.bg`) -> `Stack[ NotebookBackground, SafeArea(Column[header, Expanded(body)]) ]`, cards via `Pressable`, staggered `AnimatedEntrance`, type via `PT.*`, spacing/radius via `S`/`R`. Copy that structure for Players and Games.

Row-level actions use a **per-item `⋯` menu** (no edit mode): tapping `⋯` opens a themed anchored dropdown of actions (custom, via `showGeneralDialog` - not a Material popup or bottom sheet). See `party_card.dart` + `party_menu.dart` (`showPartyMenu` returning a `PartyAction`) and the custom `delete_party_dialog.dart`. Follow the same pattern for Players/Games instead of long-press edit mode. `HomeState` no longer has `isEditing` - that flow was removed.

Redesign one screen at a time, wiring the reference visuals to the existing cubit/repository. Keep the rest of the app on the legacy theme until its turn.

## Commands

- `flutter analyze` - keep it clean (zero issues) before finishing.
- `flutter test` - full suite (DAOs, cubits, repositories, migrations). Keep green.
- `flutter run -d <deviceId>` - run on a device/simulator. `flutter devices` to list.

## Working agreements

- **Do NOT run builds in the background.** Run them in the foreground so the user stays in control.
- Never use the em dash. Use a plain `-`.
- Never add an agent as commit co-author. Only commit/push when asked.
- Never hand-edit `CHANGELOG.md` or generated files (`*.g.dart`, drift schema dumps).
- In long Markdown, put each sentence on its own line.
- Match the surrounding code's style, naming, and comment density.
- Multiple agents may run in parallel on independent tasks - keep changes scoped to your task and avoid touching shared files (`app_theme.dart`, `app_router.dart`, `locator.dart`, `home_shell.dart`) unless your task is about them.

## Parallel worktrees

Screen redesigns run in parallel via git worktrees (one agent per worktree), opened together in the `pointolio.code-workspace` multi-root workspace:

- `pointolio/` -> branch `dev` (integration branch; Parties lives here)
- `pointolio-player-redesign/` -> branch `feature/player-redesign`
- `pointolio-games-redesign/` -> branch `feature/games-redesign`

All worktrees share one `.git`, so a commit in one is instantly visible to the others as a ref.

Conventions:

- Do your work on your own `feature/*` branch. Do not commit to `dev` from a feature worktree.
- Before starting and whenever you need the latest shared code (theme, `Pressable`, tokens, router), run `git merge dev` (or `git rebase dev`) to pull it in. `dev` is the source of truth for shared infrastructure.
- Shared files (`pointolio_theme.dart`, `pointolio_tokens.dart`, `motion.dart`, `notebook_background.dart`, `player_avatar.dart`, `home_shell.dart`, `app_router.dart`, `CLAUDE.md`) are prime conflict spots - prefer adding new widgets over editing these, and coordinate through `dev`.
- When a screen is done and green (`flutter analyze` + `flutter test`), merge its `feature/*` branch into `dev`; the other worktrees then `git merge dev` to stay current.
- Only commit/push when the user asks.
