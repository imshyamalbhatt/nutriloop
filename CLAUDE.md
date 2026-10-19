# NutriLoop

Fitness and diet app for Shyamal and friends. Tagline: **Little habits. Better days.**
Gujarati vegetarian meal plans (no egg, no meat; onion/garlic unless the user picks Jain) sized to each
person's body, goal (lose fat / stay fit / build muscle) and workout; food log with calories, protein,
carbs, fat and fibre; water tracking; reminders (water, meals, workout, stretch, eye, kitchen closed,
sleep, weekly weigh-in, protein check); weight + 7-day progress; Google sign-in with backup to the
user's own Drive. Personal-use app, no experts or paid APIs.

## How it's built
- Single file `index.html` (inline CSS + JS, no build step, no framework), same pattern as
  Pocket Money (`..\expense-tracker`) and Kachuful (`..\kachuful`).
- Data: `localStorage['nutriloop.v1']` = `{ v, profile, logs{date: {items, water, workout, done, walk, fast, swap}}, weights[{date,kg}], foods[] (custom), rem{...}, settings, account }`.
  Logged items keep their own nutrition copy (`n, u, q, kcal, p, c, f, fb, slot`) so editing the food
  list never changes history. Never rename keys or shapes without migrating (`migrate()`).
- Food list: `FOOD_TEXT` (per household unit: rotli, katori, bowl…). Meal plans: `TPL`; `*` marks the
  staple that gets scaled to the calorie target; Jain swaps in `JAIN_SWAP`; `fast: 1` = farali.
- Targets: Mifflin-St Jeor × activity, goal adjustment, workout-day burn (MET), protein g/kg, water 35 ml/kg (+0.5 L on workout days). Explained in-app (ⓘ).
- Health score 0–100: `healthScore()` (protein, fibre up; fried, sugary, very fatty down).
- Brand: forest green from the logo (`--hdr1 #0A5C3C`, `--hdr2 #03301F`), brand `#0C9A5B`, lime `#B5EE4F`
  accent, Inter, Lucide icons in the `ICONS` map (add from `lucide-static`), no emoji as icons, calm
  visuals (Shyamal dislikes busy animation). Logo source: `design/logo-source.png`; `tools/make-icons.ps1`
  builds every icon.
- UI rules carried over from Pocket Money: phone keyboard for numbers (`inputmode`), no alert/confirm
  (use `dialog()` / `ask()`), page behind sheets doesn't scroll, app text not selectable, explanations behind ⓘ.

## Native (APK stage, not built yet)
- Plan: Capacitor project `C:\Users\bhatt\android-build\nutriloop`, appId `com.shyamal.nutriloop`, same
  toolchain + debug keystore as Pocket Money (never change the key). Loader fetches the live
  `index.html` from GitHub Pages (https://imshyamalbhatt.github.io/nutriloop/), accepts it only if it
  contains `id="tab-home"` and ends in `</html>`; the app writes `nutriloop.boot = ok` after first render.
- Plugins needed: LocalNotifications (reminders, action buttons "Drank a glass" / "Done"), App (back
  button, resume), Filesystem + Share (export), plus `GoogleDrive.java` copied from Pocket Money
  (package renamed). Google Cloud: new Android OAuth client for `com.shyamal.nutriloop` + SHA-1, scopes
  `drive.appdata`, `email`, `profile`, and **Publish app** so friends can sign in (non-sensitive scopes, no review).
- Everything native is guarded by `plugin(name)`, so the same file runs in the laptop preview.

## Workflow
- Preview: `node tools/serve.js` (start detached) → http://localhost:5190 (phone frame) in VS Code's
  Simple Browser. Shyamal checks localhost first; push / build only after he approves.
- Preview switches: `?demo=1` sample data, `?fresh=1` new install, `?tab=meals|progress|me`,
  `?open=add|reminders|profile`. On localhost the Google sign-in is a stand-in account and reminders show
  as an in-app banner.
- Camera food scan is parked: it needs a paid AI vision API and he wants it only if free.
