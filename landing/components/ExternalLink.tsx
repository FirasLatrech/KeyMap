import type { AnchorHTMLAttributes } from "react";

type Props = AnchorHTMLAttributes<HTMLAnchorElement>;

/// Anchor that opens in a new tab with safe `rel` defaults. Use for every
/// off-site link (GitHub, Raycast, releases) so a click never loses the page.
export function ExternalLink({ children, ...rest }: Props) {
  return (
    <a target="_blank" rel="noopener noreferrer" {...rest}>
      {children}
    </a>
  );
}
