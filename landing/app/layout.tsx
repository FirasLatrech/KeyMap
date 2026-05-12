import type { Metadata } from "next";
import { GeistSans } from "geist/font/sans";
import { GeistMono } from "geist/font/mono";
import "./globals.css";

export const metadata: Metadata = {
  title: "KeyMap Fix — One hotkey. Right alphabet.",
  description:
    "Convert mis-typed text between Arabic, English, and French keyboard layouts in any macOS app. One keystroke.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${GeistSans.variable} ${GeistMono.variable}`}>
      <body className="bg-bg text-text antialiased">{children}</body>
    </html>
  );
}
