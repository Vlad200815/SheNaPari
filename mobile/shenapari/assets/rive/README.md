# Rive animations

`rating_stars.riv` — the stars in the rating sheet.

- Source: «Rating animation» by **JcToon**,
  https://rive.app/marketplace/405-6776-rating-animation/
- License: CC BY 4.0, https://creativecommons.org/licenses/by/4.0/
  (also registered in the app's `LicenseRegistry`, `lib/app/bootstrap.dart`).
- Changed by ШеНаПарі: colours only (transparent background, brand-yellow
  filled stars, pale-yellow empty ones, light-yellow glow) — `tool/recolor_rating_stars.py`.
- Used: artboard `New Artboard`, state machine `State Machine 1`, number input
  `rating` (0–5). Taps are handled in Flutter (`RiveRatingStars`).
