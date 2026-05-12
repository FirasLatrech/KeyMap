"use client";

import { useEffect, useRef } from "react";
import { GITHUB_REPO } from "@/lib/links";

interface Props {
  open: boolean;
  onClose: () => void;
}

const STAR_URL = `${GITHUB_REPO}`;

export function StarModal({ open, onClose }: Props) {
  const closeBtnRef = useRef<HTMLButtonElement | null>(null);

  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    document.addEventListener("keydown", onKey);
    closeBtnRef.current?.focus();
    document.body.style.overflow = "hidden";
    return () => {
      document.removeEventListener("keydown", onKey);
      document.body.style.overflow = "";
    };
  }, [open, onClose]);

  if (!open) return null;

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="star-title"
      className="fixed inset-0 z-50 flex items-center justify-center px-4"
      onClick={onClose}
    >
      <div className="absolute inset-0 bg-black/80 backdrop-blur-sm" aria-hidden />

      <div
        className="relative z-10 w-full max-w-md rounded-2xl border border-border bg-surface p-7 shadow-2xl"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-start justify-between gap-4">
          <div className="flex items-center gap-3">
            <span className="inline-flex h-10 w-10 items-center justify-center rounded-full bg-accent/15 text-accent">
              <CheckIcon />
            </span>
            <div>
              <h2 id="star-title" className="text-lg font-semibold">
                Download started
              </h2>
              <p className="text-xs text-text-muted">KeyMap-1.1.0.dmg</p>
            </div>
          </div>
          <button
            ref={closeBtnRef}
            onClick={onClose}
            className="text-text-muted hover:text-text transition-colors"
            aria-label="Close"
          >
            <CloseIcon />
          </button>
        </div>

        <p className="mt-5 text-sm text-text-muted leading-relaxed">
          If KeyMap saves you from one retyped paragraph this week, a star on
          GitHub costs you a click and helps others find it.
        </p>

        <div className="mt-6 flex flex-col gap-2">
          <a
            href={STAR_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex h-11 items-center justify-center gap-2 rounded-md bg-accent text-bg font-medium text-sm hover:bg-accent/90 transition-colors"
          >
            <StarIcon /> Star on GitHub
          </a>
          <button
            onClick={onClose}
            className="inline-flex h-9 items-center justify-center text-xs text-text-muted hover:text-text transition-colors"
          >
            Maybe later
          </button>
        </div>

        <div className="mt-6 pt-4 border-t border-border text-xs text-text-muted leading-relaxed">
          <strong className="text-text font-medium">First launch:</strong> right-click <span className="font-mono">KeyMap.app</span> →
          <span className="font-mono"> Open</span> → <span className="font-mono">Open Anyway</span>. Then grant Accessibility permission when prompted.
        </div>
      </div>
    </div>
  );
}

function CheckIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 20 20" fill="none" aria-hidden>
      <path
        d="M4.5 10.5 8 14l7.5-8"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function CloseIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 20 20" fill="none" aria-hidden>
      <path
        d="M5 5l10 10M15 5L5 15"
        stroke="currentColor"
        strokeWidth="1.75"
        strokeLinecap="round"
      />
    </svg>
  );
}

function StarIcon() {
  return (
    <svg width="14" height="14" viewBox="0 0 16 16" fill="currentColor" aria-hidden>
      <path d="M8 .25a.75.75 0 01.673.418l1.882 3.815 4.21.612a.75.75 0 01.416 1.279l-3.046 2.97.719 4.192a.75.75 0 01-1.088.791L8 12.347l-3.766 1.98a.75.75 0 01-1.088-.79l.72-4.194L.818 6.374a.75.75 0 01.416-1.28l4.21-.61L7.327.668A.75.75 0 018 .25z" />
    </svg>
  );
}
