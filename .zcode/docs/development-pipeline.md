# Game Studio Development Pipeline

This framework follows a strict professional pipeline—it ensures that architecture is decided before code is written, that tests are defined alongside features, and that cross-disciplinary domains (art, audio, design) stay synchronized.

## 1. Inception & Concept Phase (Starting from Scratch)
*This phase is about answering "What are we building?" before touching any code.*

* `/start` - Guides you on where to begin if you have a blank slate.
* `/setup-engine` - Initializes project constraints based on your engine (Godot/Unity/Unreal).
* `/brainstorm` - Fleshes out raw ideas into a structured game concept.
* `/prototype` - Builds a throwaway HTML/Engine prototype to see if the core loop is fun.
* `/art-bible` - Defines the visual identity and constraints before any assets are generated.
* `/map-systems` - Decomposes the approved concept into a checklist of necessary game systems.

## 2. Pre-Production (Design & Architecture)
*This phase creates the blueprints. No feature code should be written yet.*

* `/design-system` - You run this for *each* system mapped out in the previous step to write its Game Design Document (GDD).
* `/ux-design` - Writes the UI/UX flows and HUD specifications based on the GDDs.
* `/review-all-gdds` - Cross-checks all your GDDs for conflicting mechanics or economic imbalances.
* `/create-architecture` - Translates the design docs into technical architecture (networking models, data structures).
* `/architecture-review` - Validates that the architecture fully supports the design.
* `/create-control-manifest` - Creates the master rulebook for the AI programmers based on the architecture.
* `/test-setup` - Scaffolds the testing framework for your chosen engine.
* `/vertical-slice` - You build one tiny, fully-polished slice of the game to prove the pipeline works.

## 3. Production Planning (Agile Breakdown)
*Taking the blueprints and creating the task backlog.*

* `/create-epics` - Groups the architecture into large Epics (e.g., "Combat System", "Inventory").
* `/create-stories` - Breaks Epics into bite-sized, implementable tasks (`.story.md` files).
* `/estimate` - Estimates complexity and effort for the stories.
* `/qa-plan` - Writes the test plan for how these stories will be verified.
* `/sprint-plan` - Groups stories into a 2-week sprint backlog.

## 4. The Implementation Loop (The Daily Grind)
*This is the loop you repeat for every single feature.*

* `/story-readiness` - Validates that a story has enough detail to start coding.
* `/dev-story` - **The core coding command.** The AI reads the story, writes the code, and writes the test.
* `/code-review` - Reviews the generated code against the Control Manifest.
* `/story-done` - Marks the story complete and surfaces the next one from the sprint.

**When things go wrong during implementation:**
* `/bug-report` -> `/systematic-debugging` (Skill) -> `/bug-triage` -> `/regression-suite`

**When designs change mid-flight:**
* `/quick-design` (for small tweaks) or `/propagate-design-change` (updates GDDs and downstream docs).

## 5. Multi-Agent Orchestration (Building Content)
*Once the core code systems exist, you use orchestration commands to build out the actual game content using multiple specialized subagents.*

* `/team-level` - Orchestrates level/world building.
* `/team-combat` - Orchestrates enemies, weapons, and AI.
* `/team-ui` - Orchestrates menus and interfaces.
* `/team-audio` - Orchestrates soundscapes and mixing.
* `/team-narrative` - Orchestrates dialogue and quest logic.

## 6. Polish, QA & Hardening
*Preparing the game for human hands.*

* `/smoke-check` - Runs critical path tests to ensure the build isn't completely broken.
* `/balance-check` - The AI analyzes your data tables to find economy exploits or overpowered weapons.
* `/perf-profile` - Analyzes framerates, draw calls, and memory leaks.
* `/security-audit` - Checks for multiplayer exploits or save-game tampering vulnerabilities.
* `/asset-audit` & `/content-audit` - Scans the project to find missing art, orphaned files, or unfulfilled GDD requirements.
* `/ux-review` - Validate UX specs against implementation.
* `/playtest-report` - You hand the game to a human; the AI analyzes their feedback.

## 7. Release & Live Ops
*Shipping the game and maintaining it.*

* `/launch-checklist` - Final sign-offs (store assets, build certification, marketing).
* `/day-one-patch` - Scopes and implements fixes for issues discovered right before launch.
* `/patch-notes` & `/changelog` - Translates your git commits into exciting player-facing patch notes.
* `/hotfix` - Bypasses the sprint process for emergency game-breaking fixes.
* `/team-live-ops` - Orchestrates the planning for Season 2 content or DLC.

---

## If You Get Lost
At any point during development, you have navigational lifelines:

* `/help` - Analyzes the project state and tells you exactly what to do next.
* `/sprint-status` - Tells you if you're behind schedule.
* `/project-stage-detect` - Audits everything and tells you what development phase you are currently in.
