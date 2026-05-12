export function Keycap({ children, wide = false }: { children: React.ReactNode; wide?: boolean }) {
  return (
    <span
      className={`inline-flex items-center justify-center font-mono text-[13px] font-medium text-text bg-surface border border-border rounded-md ${
        wide ? "px-2.5 h-8 min-w-[2rem]" : "h-8 w-8"
      }`}
      style={{ boxShadow: "inset 0 -2px 0 0 rgba(0,0,0,0.4), 0 1px 0 0 rgba(255,255,255,0.04)" }}
    >
      {children}
    </span>
  );
}
