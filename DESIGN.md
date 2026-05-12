# KeyMap Fix — Design Prompt

Use this prompt with v0, Lovable, Figma Make, Claude, or as a Figma brief.

---

## Master prompt (paste verbatim into v0 / Claude / Lovable)

> Design a Raycast extension UI and a companion landing page for **KeyMap Fix** — a macOS utility that converts mis-typed text between Arabic and English (and AZERTY French) keyboard layouts via a single hotkey.
>
> **Brand personality:** Technical, minimal, slightly playful. Aimed at developers and bilingual knowledge workers in the MENA region. Should feel like a tool made by someone who actually has this problem — not a generic SaaS landing page.
>
> **Visual references:**
> - Trigger.dev (developer-first aesthetic, dark mode primary, bold typography)
> - Raycast itself (clean command palette UX)
> - Linear (precision, generous whitespace, monochrome with one accent color)
>
> **Type:**
> - Latin: Inter or Geist (variable weight 400 / 500 / 700)
> - Arabic: IBM Plex Sans Arabic (matches Geist proportionally), 500/700
> - Mono: Geist Mono or JetBrains Mono for code/keys
>
> **Color system (dark mode primary):**
> - Background: `#0A0A0A` (near-black, not pure black)
> - Surface: `#141414`
> - Border: `#262626`
> - Text primary: `#FAFAFA`
> - Text muted: `#A1A1AA`
> - Accent: `#7C5CFF` (electric violet — distinctive, not the typical SaaS blue)
> - Success: `#22D3A5`
> - Arabic-context accent (subtle): `#F59E0B` (warm amber, evokes coffee / Tunisian context)
>
> **Light mode:** invert with the same accents. Provide both.
>
> **Components to design:**
>
> 1. **Raycast extension main view** — Command-palette style. Input field at top, live preview underneath showing converted text. Direction indicator (AR → EN or EN → AR) as a small pill. Bottom action bar: ⏎ Copy, ⌘+R Reverse, ⌘+, Preferences.
>
> 2. **Raycast preferences panel** — Native Raycast preferences style: hotkey picker, default direction dropdown, AZERTY toggle, toast notification toggle.
>
> 3. **Toast notification** — Small floating card shown after invocation: "Converted EN → AR" with a tiny direction arrow icon. Auto-dismiss 1.5s.
>
> 4. **Landing page (single scroll)**, sections in order:
>    - **Hero:** Headline that lands the problem in one line. Subhead in one sentence. Animated demo above the fold showing `hgsghl` → `السلام` with the hotkey ⌥⌘K visualized as keycaps. CTA: "Install from Raycast Store".
>    - **The problem:** Side-by-side: "Before" (frustrated user retyping) vs "After" (one keystroke). Use real Arabic and French examples.
>    - **How it works:** Three steps with icons: Select → Press ⌥⌘K → Done. Show the keyboard mapping concept visually (Arabic letter overlaid on Latin keycap).
>    - **Layouts supported:** Three cards — AR ↔ EN, FR ↔ EN (AZERTY), more coming. Each card shows a mini example.
>    - **Privacy:** One-line callout — "100% local. Zero network calls. Your text never leaves your Mac." With a small lock icon.
>    - **Footer:** Built in Tunis 🇹🇳, GitHub link, Raycast Store link.
>
> **Hero headline options:**
> - "Stop retyping `hgsghl`."
> - "One hotkey. Right alphabet."
> - "Wrong keyboard? Fixed."
>
> **Subhead:** "Convert mis-typed text between Arabic, English, and French keyboard layouts in any macOS app. One keystroke."
>
> **Critical UI details:**
> - All Arabic text right-aligned with proper RTL handling — `dir="rtl"` and `lang="ar"` on relevant elements.
> - Show actual realistic Arabic (السلام عليكم, شكرا, ما عندي وقت) — not lorem ipsum.
> - Keycaps rendered as small 3D-ish elements: 32px square, subtle border, mono font, slight inset shadow.
> - The animated hero demo: typed characters appear one at a time on the left, then on hotkey press, they morph to the converted version on the right. ~3s loop.
> - No stock photography. No illustrations of people. Use abstract geometric shapes or keyboard imagery only.
> - No gradient backgrounds. Solid surfaces with subtle borders.
>
> **What NOT to do:**
> - No "AI-powered" language anywhere — this is deterministic, not AI.
> - No emoji in marketing copy (the footer flag is the only one).
> - No "Get started for free" — it's a free open tool. Use "Install" or "Add to Raycast".
> - No testimonials section (we don't have any yet, and fake ones erode trust).
> - No animated gradient backgrounds. No glassmorphism. No frosted blur effects on cards.

---

## Figma-specific addendum

If designing in Figma:

- Set up two pages: `01 — Raycast Extension`, `02 — Landing Page`.
- Use Auto Layout with `gap: 8 / 12 / 16 / 24 / 32 / 48` as the only spacing values.
- Frame sizes: Raycast extension 750×475 (Raycast's actual window size). Landing page 1440 desktop + 390 mobile artboards.
- Components needed: `Keycap`, `Pill`, `Toast`, `ConversionRow`, `LayoutCard`, `HeroDemoFrame`.
- Variables: create color tokens matching the palette above so light/dark mode swaps are one click.

---

## v0 / Lovable shortcut prompt

For just the landing page (paste in v0):

> Build a single-scroll landing page in Next.js + Tailwind for "KeyMap Fix", a macOS Raycast extension that converts mis-typed Arabic/English/French keyboard text in one hotkey. Dark mode (#0A0A0A bg, #FAFAFA text, #7C5CFF accent). Use Geist for Latin text and IBM Plex Sans Arabic for Arabic. Sections: animated hero demo (hgsghl → السلام with keycap visualization of ⌥⌘K), problem/solution, three-step how-it-works, supported layouts (AR↔EN, FR↔EN), privacy callout (100% local), footer. Use real Arabic examples (السلام عليكم, شكرا). All Arabic must be RTL with proper `dir="rtl"`. No gradients, no stock photos, no AI-buzzwords. Made in Tunis vibe — technical and minimal, not corporate.

---

## Demo copy for the animated hero

Loop these three pairs (3 seconds each):

| Wrong | Right | Direction |
|-------|-------|-----------|
| `hgsghl ugd;l` | `السلام عليكم` | EN → AR |
| `a;vh` | `شكرا` | EN → AR |
| `qzerty` | `azerty` | EN → FR |

---

## Asset checklist

- [ ] App icon (1024×1024 .png) — abstract glyph combining Latin "K" and Arabic "ك"
- [ ] Raycast extension icon (512×512)
- [ ] Hero demo screenshot
- [ ] Favicon (32×32)
- [ ] README banner (1280×640) for GitHub
