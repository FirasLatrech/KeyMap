// Canonical external URLs for the landing page. Keep them here so every CTA
// stays in sync when we cut a new release.

export const GITHUB_REPO = "https://github.com/FirasLatrech/KeyMap";
export const RAYCAST_PR  = "https://github.com/raycast/extensions/pull/27836";

/// Latest GitHub release. The "latest" alias resolves to whatever release we
/// publish, so cutting v1.2.0 will Just Work without touching the landing page.
export const LATEST_RELEASE_PAGE = `${GITHUB_REPO}/releases/latest`;
export const LATEST_DMG_URL =
  `${GITHUB_REPO}/releases/latest/download/KeyMap-1.1.0.dmg`;

export const APP_VERSION = "1.1.0";
