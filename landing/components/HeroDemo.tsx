"use client";

import { useEffect, useState } from "react";
import { Keycap } from "./Keycap";

type Pair = { wrong: string; right: string; direction: string; lang?: "ar" | "fr" };

const PAIRS: Pair[] = [
  { wrong: "hgsghl ugd;l", right: "السلام عليكم", direction: "EN → AR", lang: "ar" },
  { wrong: "a;vh", right: "شكرا", direction: "EN → AR", lang: "ar" },
  { wrong: "qzerty", right: "azerty", direction: "EN → FR", lang: "fr" },
];

const TYPE_MS = 90;
const HOLD_MS = 700;
const CONVERT_MS = 600;
const REST_MS = 1100;

export function HeroDemo() {
  const [idx, setIdx] = useState(0);
  const [typed, setTyped] = useState("");
  const [converted, setConverted] = useState(false);

  useEffect(() => {
    const pair = PAIRS[idx];
    let cancelled = false;

    const run = async () => {
      setTyped("");
      setConverted(false);
      for (let i = 1; i <= pair.wrong.length; i++) {
        if (cancelled) return;
        await wait(TYPE_MS);
        setTyped(pair.wrong.slice(0, i));
      }
      await wait(HOLD_MS);
      if (cancelled) return;
      setConverted(true);
      await wait(CONVERT_MS + REST_MS);
      if (cancelled) return;
      setIdx((p) => (p + 1) % PAIRS.length);
    };

    run();
    return () => {
      cancelled = true;
    };
  }, [idx]);

  const pair = PAIRS[idx];
  const isArabic = pair.lang === "ar";

  return (
    <div className="w-full max-w-3xl mx-auto bg-surface border border-border rounded-2xl overflow-hidden">
      <div className="flex items-center gap-1.5 px-4 h-9 border-b border-border">
        <span className="h-2.5 w-2.5 rounded-full bg-[#3a3a3a]" />
        <span className="h-2.5 w-2.5 rounded-full bg-[#3a3a3a]" />
        <span className="h-2.5 w-2.5 rounded-full bg-[#3a3a3a]" />
        <span className="ml-3 text-[11px] font-mono text-text-muted">KeyMap Fix</span>
        <span className="ml-auto inline-flex items-center gap-1.5 text-[11px] font-mono text-text-muted">
          <span className="h-1.5 w-1.5 rounded-full bg-success" />
          ready
        </span>
      </div>

      <div className="p-8 sm:p-12 grid grid-cols-1 sm:grid-cols-[1fr_auto_1fr] gap-6 items-center">
        <div className="min-h-[80px] flex items-center">
          <div className="font-mono text-2xl sm:text-3xl text-text-muted break-all">
            {typed}
            <span className="inline-block w-[2px] h-7 ml-0.5 bg-text-muted align-middle animate-blink" />
          </div>
        </div>

        <div className="flex flex-col items-center gap-2 px-2">
          <div className="flex items-center gap-1.5">
            <Keycap wide>⌥</Keycap>
            <Keycap wide>⌘</Keycap>
            <Keycap>K</Keycap>
          </div>
          <span className="text-[10px] font-mono text-text-muted tracking-wider uppercase">
            {pair.direction}
          </span>
        </div>

        <div className="min-h-[80px] flex items-center justify-end" dir={isArabic ? "rtl" : "ltr"}>
          <div
            lang={pair.lang ?? "en"}
            className={`text-2xl sm:text-3xl font-medium transition-all duration-500 ${
              converted ? "opacity-100 translate-y-0 text-text" : "opacity-0 translate-y-1 text-text-muted"
            } ${isArabic ? "font-arabic" : "font-sans"}`}
          >
            {pair.right}
          </div>
        </div>
      </div>
    </div>
  );
}

function wait(ms: number) {
  return new Promise<void>((res) => setTimeout(res, ms));
}
