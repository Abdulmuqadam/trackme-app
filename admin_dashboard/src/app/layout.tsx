import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "TrackMe Admin Dashboard",
  description: "Organization management for TrackMe emergency response platform",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="bg-slate-50 text-slate-900 antialiased">{children}</body>
    </html>
  );
}
