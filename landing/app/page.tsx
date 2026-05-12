import { HeroDemo } from "@/components/HeroDemo";
import { Keycap } from "@/components/Keycap";

export default function Page() {
  return (
    <main className="min-h-screen">
      <Nav />
      <Hero />
      <Problem />
      <HowItWorks />
      <Layouts />
      <Privacy />
      <Footer />
    </main>
  );
}

function Nav() {
  return (
    <nav className="border-b border-border">
      <div className="max-w-6xl mx-auto px-6 h-14 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <Logo />
          <span className="font-mono text-sm font-medium">KeyMap Fix</span>
        </div>
        <a
          href="https://www.raycast.com/store"
          className="text-sm text-text-muted hover:text-text transition-colors"
        >
          Raycast Store →
        </a>
      </div>
    </nav>
  );
}

function Logo() {
  return (
    <span
      aria-hidden
      className="inline-flex items-center justify-center h-6 w-6 rounded bg-accent/15 border border-accent/30 text-accent font-mono text-[11px] font-bold"
    >
      K
    </span>
  );
}

function Hero() {
  return (
    <section className="px-6 pt-24 pb-20 sm:pt-32 sm:pb-28">
      <div className="max-w-6xl mx-auto flex flex-col items-center text-center gap-8">
        <span className="inline-flex items-center gap-2 px-3 h-7 rounded-full border border-border bg-surface text-[11px] font-mono text-text-muted tracking-wider uppercase">
          <span className="h-1.5 w-1.5 rounded-full bg-accent" />
          Raycast extension · macOS
        </span>

        <h1 className="text-5xl sm:text-7xl font-semibold tracking-tight max-w-3xl">
          One hotkey. <span className="text-accent">Right alphabet.</span>
        </h1>

        <p className="text-lg sm:text-xl text-text-muted max-w-2xl leading-relaxed">
          Convert mis-typed text between Arabic, English, and French keyboard layouts in any macOS app. One keystroke.
        </p>

        <div className="flex items-center gap-3 pt-2">
          <a
            href="#install"
            className="inline-flex items-center gap-2 h-11 px-5 rounded-md bg-text text-bg font-medium text-sm hover:bg-text-muted transition-colors"
          >
            Install from Raycast Store
          </a>
          <a
            href="https://github.com/firaslatrach/keymap-fix"
            className="inline-flex items-center gap-2 h-11 px-5 rounded-md border border-border bg-surface text-text font-medium text-sm hover:border-text-muted transition-colors"
          >
            View on GitHub
          </a>
        </div>

        <div className="w-full pt-12">
          <HeroDemo />
        </div>
      </div>
    </section>
  );
}

function Problem() {
  return (
    <section className="px-6 py-24 border-t border-border">
      <div className="max-w-6xl mx-auto">
        <SectionLabel>The problem</SectionLabel>
        <h2 className="text-3xl sm:text-4xl font-semibold tracking-tight mt-3 max-w-2xl">
          You meant to switch keyboards. You didn&apos;t. Now you&apos;re retyping a paragraph.
        </h2>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mt-12">
          <Card title="Before" tone="muted">
            <Row label="You typed">
              <code className="font-mono text-lg text-text-muted">hgsghl ugd;l</code>
            </Row>
            <Row label="You meant" rtl>
              <span lang="ar" className="font-arabic text-lg text-text-muted">
                السلام عليكم
              </span>
            </Row>
            <div className="text-sm text-text-muted pt-3 border-t border-border">
              Delete. Switch input source. Retype. Hope you remembered the diacritics.
            </div>
          </Card>

          <Card title="After" tone="accent">
            <Row label="You typed">
              <code className="font-mono text-lg">hgsghl ugd;l</code>
            </Row>
            <Row label="You pressed">
              <span className="inline-flex items-center gap-1.5">
                <Keycap wide>⌥</Keycap>
                <Keycap wide>⌘</Keycap>
                <Keycap>K</Keycap>
              </span>
            </Row>
            <Row label="You have" rtl>
              <span lang="ar" className="font-arabic text-lg">
                السلام عليكم
              </span>
            </Row>
          </Card>
        </div>
      </div>
    </section>
  );
}

function Row({ label, children, rtl = false }: { label: string; children: React.ReactNode; rtl?: boolean }) {
  return (
    <div className="flex items-center justify-between gap-4 py-2">
      <span className="text-[11px] font-mono text-text-muted tracking-wider uppercase shrink-0">
        {label}
      </span>
      <div dir={rtl ? "rtl" : "ltr"} className={rtl ? "text-right" : "text-left"}>
        {children}
      </div>
    </div>
  );
}

function Card({
  title,
  children,
  tone,
}: {
  title: string;
  children: React.ReactNode;
  tone: "muted" | "accent";
}) {
  return (
    <div
      className={`rounded-xl border bg-surface p-6 flex flex-col gap-1 ${
        tone === "accent" ? "border-accent/40" : "border-border"
      }`}
    >
      <div className="flex items-center justify-between pb-3">
        <span className="text-sm font-medium">{title}</span>
        {tone === "accent" && (
          <span className="text-[10px] font-mono text-accent tracking-wider uppercase">
            with KeyMap
          </span>
        )}
      </div>
      {children}
    </div>
  );
}

function HowItWorks() {
  const steps = [
    { n: "01", title: "Select your text", body: "Highlight the gibberish in any macOS app — Slack, Notes, your editor, anywhere." },
    { n: "02", title: "Press ⌥⌘K", body: "KeyMap detects the script and converts the selection in place. No menus. No dialogs." },
    { n: "03", title: "Keep working", body: "A small toast confirms the direction. Hit ⌘+R inside Raycast to reverse if you guessed wrong." },
  ];
  return (
    <section className="px-6 py-24 border-t border-border">
      <div className="max-w-6xl mx-auto">
        <SectionLabel>How it works</SectionLabel>
        <h2 className="text-3xl sm:text-4xl font-semibold tracking-tight mt-3 max-w-2xl">
          Three steps. The middle one is a keystroke.
        </h2>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mt-12">
          {steps.map((s) => (
            <div key={s.n} className="rounded-xl border border-border bg-surface p-6 flex flex-col gap-3">
              <span className="font-mono text-xs text-text-muted">{s.n}</span>
              <h3 className="text-lg font-medium">{s.title}</h3>
              <p className="text-sm text-text-muted leading-relaxed">{s.body}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function Layouts() {
  const cards = [
    {
      tag: "AR ↔ EN",
      title: "Arabic ⇄ English",
      example: { from: "a;vh", to: "شكرا", lang: "ar" as const },
      status: "Stable",
    },
    {
      tag: "FR ↔ EN",
      title: "AZERTY ⇄ QWERTY",
      example: { from: "qwerty", to: "azerty", lang: "fr" as const },
      status: "Stable",
    },
    {
      tag: "Soon",
      title: "Hebrew, Russian, Greek",
      example: { from: "—", to: "Vote on GitHub", lang: "fr" as const },
      status: "Planned",
    },
  ];
  return (
    <section className="px-6 py-24 border-t border-border">
      <div className="max-w-6xl mx-auto">
        <SectionLabel>Supported layouts</SectionLabel>
        <h2 className="text-3xl sm:text-4xl font-semibold tracking-tight mt-3 max-w-2xl">
          Built for bilingual keyboards.
        </h2>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mt-12">
          {cards.map((c) => {
            const rtl = c.example.lang === "ar";
            return (
              <div key={c.title} className="rounded-xl border border-border bg-surface p-6 flex flex-col gap-4">
                <div className="flex items-center justify-between">
                  <span className="text-[10px] font-mono text-accent tracking-wider uppercase">
                    {c.tag}
                  </span>
                  <span className="text-[10px] font-mono text-text-muted tracking-wider uppercase">
                    {c.status}
                  </span>
                </div>
                <h3 className="text-lg font-medium">{c.title}</h3>
                <div className="rounded-md border border-border bg-bg p-4 flex items-center justify-between gap-3 mt-2">
                  <code className="font-mono text-sm text-text-muted">{c.example.from}</code>
                  <span className="text-text-muted">→</span>
                  <span
                    dir={rtl ? "rtl" : "ltr"}
                    lang={c.example.lang}
                    className={`text-sm ${rtl ? "font-arabic text-base" : "font-mono"}`}
                  >
                    {c.example.to}
                  </span>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}

function Privacy() {
  return (
    <section className="px-6 py-20 border-t border-border">
      <div className="max-w-3xl mx-auto rounded-xl border border-border bg-surface p-8 flex items-start gap-4">
        <LockIcon />
        <div className="flex flex-col gap-2">
          <h3 className="text-lg font-medium">100% local. Zero network calls.</h3>
          <p className="text-sm text-text-muted leading-relaxed">
            KeyMap runs entirely on your Mac. The conversion is a deterministic character map — there is no
            model, no telemetry, no analytics. Your text never leaves the machine.
          </p>
        </div>
      </div>
    </section>
  );
}

function LockIcon() {
  return (
    <span className="inline-flex items-center justify-center h-9 w-9 rounded-md border border-accent/30 bg-accent/10 text-accent shrink-0">
      <svg width="16" height="16" viewBox="0 0 16 16" fill="none" aria-hidden>
        <rect x="3" y="7" width="10" height="6.5" rx="1.5" stroke="currentColor" strokeWidth="1.5" />
        <path d="M5.5 7V5a2.5 2.5 0 015 0v2" stroke="currentColor" strokeWidth="1.5" />
      </svg>
    </span>
  );
}

function Footer() {
  return (
    <footer className="px-6 py-12 border-t border-border">
      <div className="max-w-6xl mx-auto flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div className="flex items-center gap-2 text-sm text-text-muted">
          <Logo />
          <span className="font-mono">KeyMap Fix</span>
          <span>·</span>
          <span>Built in Tunis 🇹🇳</span>
        </div>
        <div className="flex items-center gap-5 text-sm text-text-muted">
          <a href="https://github.com/firaslatrach/keymap-fix" className="hover:text-text transition-colors">
            GitHub
          </a>
          <a href="https://www.raycast.com/store" className="hover:text-text transition-colors">
            Raycast Store
          </a>
        </div>
      </div>
    </footer>
  );
}

function SectionLabel({ children }: { children: React.ReactNode }) {
  return (
    <span className="inline-flex items-center gap-2 text-[11px] font-mono text-accent tracking-wider uppercase">
      <span className="h-px w-6 bg-accent" />
      {children}
    </span>
  );
}
