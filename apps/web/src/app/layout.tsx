import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "OsmoControl Web",
  description: "Osmo device control dashboard",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="zh">
      <body>{children}</body>
    </html>
  );
}
