"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import clsx from "clsx";
import { useAuth } from "@/hooks/useAuth";

const navItems = [
  { label: "Dashboard", href: "/dashboard", icon: "📊" },
  { label: "Users", href: "/dashboard/users", icon: "👥" },
  { label: "Facilitators", href: "/dashboard/facilitators", icon: "🚨" },
  { label: "Analytics", href: "/dashboard/analytics", icon: "📈" },
  { label: "Billing", href: "/dashboard/billing", icon: "💳" },
  { label: "Settings", href: "/dashboard/settings", icon: "⚙️" },
];

export default function Sidebar() {
  const pathname = usePathname();
  const { logout, user } = useAuth();

  return (
    <aside className="flex h-screen w-64 flex-col border-r border-gray-200 bg-white px-4 py-6 shadow-sm">
      {/* Logo */}
      <div className="mb-8 flex items-center gap-2">
        <span className="text-2xl">🚨</span>
        <span className="text-xl font-bold text-red-600">TrackMe</span>
        <span className="text-sm text-gray-500">Admin</span>
      </div>

      {/* Org subdomain badge */}
      {user && (
        <div className="mb-6 rounded-lg bg-red-50 px-3 py-2 text-xs text-red-700 font-medium">
          {user.subdomain}.trackme.app
        </div>
      )}

      {/* Navigation */}
      <nav className="flex flex-1 flex-col gap-1">
        {navItems.map((item) => (
          <Link
            key={item.href}
            href={item.href}
            className={clsx(
              "flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors",
              pathname === item.href
                ? "bg-red-600 text-white"
                : "text-gray-700 hover:bg-gray-100"
            )}
          >
            <span>{item.icon}</span>
            {item.label}
          </Link>
        ))}
      </nav>

      {/* Logout */}
      <button
        onClick={logout}
        className="mt-4 flex items-center gap-2 rounded-lg px-3 py-2 text-sm font-medium text-gray-500 hover:bg-gray-100"
      >
        <span>🚪</span> Log out
      </button>
    </aside>
  );
}
