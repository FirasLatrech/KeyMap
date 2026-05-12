"use client";

import { useState } from "react";
import { StarModal } from "./StarModal";
import { DIRECT_DMG_URL } from "@/lib/links";

interface Props {
  variant?: "hero" | "install";
  children: React.ReactNode;
  className?: string;
}

/// Triggers the DMG download directly from the same origin (no GitHub redirect)
/// then opens a "star the repo" modal after a short delay so the system
/// download UI has already shown up.
export function DownloadButton({ variant = "hero", children, className }: Props) {
  const [modalOpen, setModalOpen] = useState(false);

  const handleClick = () => {
    // Open modal slightly after the click so the browser's native "Save…" /
    // download tray notification appears first.
    window.setTimeout(() => setModalOpen(true), 350);
  };

  return (
    <>
      <a
        href={DIRECT_DMG_URL}
        download
        onClick={handleClick}
        className={
          className ??
          (variant === "hero"
            ? "inline-flex items-center gap-2 h-11 px-5 rounded-md bg-text text-bg font-medium text-sm hover:bg-text-muted transition-colors"
            : "inline-flex items-center justify-center h-10 px-4 rounded-md bg-accent text-bg font-medium text-sm hover:bg-accent/90 transition-colors")
        }
      >
        {children}
      </a>
      <StarModal open={modalOpen} onClose={() => setModalOpen(false)} />
    </>
  );
}
