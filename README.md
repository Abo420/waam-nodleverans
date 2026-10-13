# WAAM Nödleverans

Prototyp för Design Thinking-projektet "The First 72 Hours" (BTH).
Drabbade beställer medicin och förnödenheter; WAAM samlar beställningarna per fastighet och packar en drönarlåda per hus.

- `index.html` – hela webbplatsen (beställningsformulär, låst logistikvy, systembeskrivning)
- `config.js` – Supabase-URL och anon-nyckel
- `setup.sql` – skapar tabellen `orders`, radsäkerhet och admin-listan

## Driftsättning
1. Kör `setup.sql` i Supabase → SQL Editor (med din e-post som admin).
2. Supabase → Authentication → Users → Add user: skapa ditt inloggningskonto (samma e-post).
3. Supabase → Authentication → Sign In / Providers: stäng av "Allow new users to sign up".
4. Fyll i `config.js` och publicera repot med GitHub Pages (Settings → Pages → Deploy from branch → main / root).
