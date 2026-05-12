// Canonical external URLs for the landing page. Keep them here so every CTA
// stays in sync when we cut a new release.

export const GITHUB_REPO = "https://github.com/FirasLatrech/KeyMap";
export const RAYCAST_PR  = "https://github.com/raycast/extensions/pull/27836";

export const APP_VERSION = "1.1.0";

// The DMG is served directly from this site (Vercel static asset) so the
// download starts instantly without bouncing through GitHub Releases.
export const DIRECT_DMG_URL = `/download/KeyMap-${APP_VERSION}.dmg`;

// GitHub Releases page kept as a secondary path (for source-tarball / history).
export const LATEST_RELEASE_PAGE = `${GITHUB_REPO}/releases`;
