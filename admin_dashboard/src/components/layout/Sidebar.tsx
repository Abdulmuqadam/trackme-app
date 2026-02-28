"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import clsx from "clsx";
import { useAuth } from "@/hooks/useAuth";

// SVG icon components (inline, no extra dependency)
function Icon({ d, ...props }: { d: string; className?: string }) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.75}
      strokeLinecap="round" strokeLinejoin="round" {...props}>
      <path d={d} />
    </svg>
  );
}

const icons: Record<string, string> = {
  Dashboard: "M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2V9z M9 22V12h6v10",
  Users: "M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2 M9 11a4 4 0 100-8 4 4 0 000 8 M23 21v-2a4 4 0 00-3-3.87 M16 3.13a4 4 0 010 7.75",
  Facilitators: "M14.5 10c-.83 0-1.5-.67-1.5-1.5v-5c0-.83.67-1.5 1.5-1.5s1.5.67 1.5 1.5v5c0 .83-.67 1.5-1.5 1.5z M20.5 10H19V8.5c0-.83.67-1.5 1.5-1.5s1.5.67 1.5 1.5-.67 1.5-1.5 1.5z M9.5 14c.83 0 1.5.67 1.5 1.5v5c0 .83-.67 1.5-1.5 1.5S8 21.33 8 20.5v-5c0-.83.67-1.5 1.5-1.5z M3.5 14H5v1.5c0 .83-.67 1.5-1.5 1.5S2 16.33 2 15.5 2.67 14 3.5 14z M14 14.5v-4 M4 9.5v-4 M9.5 10H19 M5 14.5h10",
  Analytics: "M22 12h-4l-3 9L9 3l-3 9H2",
  Billing: "M21 4H3a2 2 0 00-2 2v12a2 2 0 002 2h18a2 2 0 002-2V6a2 2 0 00-2-2z M1 10h22",
  Settings: "M12 15a3 3 0 100-6 3 3 0 000 6z M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83 0 2 2 0 010-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 010-2.83 2 2 0 012.83 0l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 0 2 2 0 010 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z",
  Logout: "M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4 M16 17l5-5-5-5 M21 12H9",
};

const navItems = [
  { label: "Dashboard",    href: "/dashboard" },
  { label: "Users",        href: "/dashboard/users" },
  { label: "Facilitators", href: "/dashboard/facilitators" },
  { label: "Analytics",    href: "/dashboard/analytics" },
  { label: "Billing",      href: "/dashboard/billing" },
  { label: "Settings",     href: "/dashboard/settings" },
];

export default function Sidebar() {
  const pathname = usePathname();
  const { logout, user } = useAuth();

  return (
    <aside
      className="flex h-screen w-64 flex-col px-4 py-6"
      style={{
        background: "linear-gradient(180deg, #0f172a 0%, #1e1b4b 100%)",
        borderRight: "1px solid rgba(255,255,255,0.06)",
      }}
    >
      {/* Logo */}
      <div className="mb-8 flex items-center gap-3 px-1">
        <div className="flex h-9 w-9 items-center justify-center rounded-xl"
          style={{ background: "linear-gradient(135deg, #f43f5e, #be123c)" }}>
          <svg viewBox="0 0 24 24" fill="white" className="h-5 w-5">
            <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z" />
          </svg>
        </div>
        <div>
          <span className="text-base font-bold text-white tracking-tight">TrackMe</span>
          <span className="ml-1.5 rounded-full bg-rose-500/20 px-1.5 py-0.5 text-[10px] font-semibold uppercase tracking-wide text-rose-400">
            Admin
          </span>
        </div>
      </div>

      {/* Org badge */}
      {user && (
        <div className="mb-6 flex items-center gap-2 rounded-xl px-3 py-2.5"
          style={{ background: "rgba(244,63,94,0.1)", border: "1px solid rgba(244,63,94,0.2)" }}>
          <div className="h-2 w-2 rounded-full bg-emerald-400 animate-pulse-glow" />
          <span className="truncate text-xs font-medium text-rose-300">
            {user.subdomain}.trackme.app
          </span>
        </div>
      )}

      {/* Navigation */}
      <nav className="flex flex-1 flex-col gap-0.5">
        <p className="mb-2 px-3 text-[10px] font-semibold uppercase tracking-widest text-slate-500">
          Navigation
        </p>
        {navItems.map((item) => {
          const isActive = pathname === item.href ||
            (item.href !== "/dashboard" && pathname.startsWith(item.href));
          return (
            <Link
              key={item.href}
              href={item.href}
              className={clsx("sidebar-nav-item", isActive && "active")}
            >
              <Icon
                d={icons[item.label]}
                className={clsx("h-4 w-4 shrink-0", isActive ? "text-rose-400" : "text-slate-500")}
              />
              {item.label}
              {isActive && (
                <span className="ml-auto h-1.5 w-1.5 rounded-full bg-rose-400" />
              )}
            </Link>
          );
        })}
      </nav>

      {/* User / Logout */}
      <div className="mt-4 border-t pt-4" style={{ borderColor: "rgba(255,255,255,0.06)" }}>
        <button
          onClick={logout}
          className="sidebar-nav-item w-full text-left hover:bg-rose-500/10 hover:text-rose-400"
        >
          <Icon d={icons.Logout} className="h-4 w-4 shrink-0 text-slate-500" />
          Log out
        </button>
      </div>
    </aside>
  );
}
