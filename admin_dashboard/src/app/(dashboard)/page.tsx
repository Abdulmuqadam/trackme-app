"use client";
import useSWR from "swr";
import Link from "next/link";
import { api } from "@/lib/api";
import type { Organization } from "@/types";

const fetcher = (url: string) => api.get(url).then((r) => r.data);

const statusColor: Record<string, string> = {
  active:    "bg-emerald-400/15 text-emerald-400",
  trial:     "bg-amber-400/15 text-amber-400",
  suspended: "bg-rose-400/15 text-rose-400",
};

export default function DashboardPage() {
  const { data: org } = useSWR<Organization>("/api/organizations/me", fetcher, {
    refreshInterval: 30000,
  });

  const metrics = [
    {
      label: "Subscription",
      value: org?.subscription_tier ?? "—",
      sub: org?.subscription_status,
      iconPath: "M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z",
      gradient: "from-violet-500/10 to-purple-600/10",
      border: "border-violet-500/20",
      iconColor: "text-violet-500",
    },
    {
      label: "Max Users",
      value: org?.max_users ?? "—",
      sub: "registered users",
      iconPath: "M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2M9 11a4 4 0 100-8 4 4 0 000 8M23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75",
      gradient: "from-blue-500/10 to-cyan-600/10",
      border: "border-blue-500/20",
      iconColor: "text-blue-500",
    },
    {
      label: "Facilitators",
      value: org?.max_facilitators ?? "—",
      sub: "response agents",
      iconPath: "M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z",
      gradient: "from-rose-500/10 to-red-600/10",
      border: "border-rose-500/20",
      iconColor: "text-rose-500",
    },
    {
      label: "Trial Ends",
      value: org?.trial_ends_at
        ? new Date(org.trial_ends_at).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })
        : "Active",
      sub: "next billing date",
      iconPath: "M8 2v4M16 2v4M3 10h18M5 4h14a2 2 0 012 2v14a2 2 0 01-2 2H5a2 2 0 01-2-2V6a2 2 0 012-2z",
      gradient: "from-amber-500/10 to-orange-600/10",
      border: "border-amber-500/20",
      iconColor: "text-amber-500",
    },
  ];

  const quickLinks = [
    { label: "Manage Users",  desc: "View and control user accounts", href: "/dashboard/users",      icon: "👥", gradient: "from-blue-500/10 to-cyan-500/10",   border: "border-blue-500/20" },
    { label: "View Analytics",desc: "Query trends and resolution rates",href: "/dashboard/analytics", icon: "📈", gradient: "from-violet-500/10 to-purple-500/10",border: "border-violet-500/20" },
    { label: "Billing",       desc: "Manage plan and payments",        href: "/dashboard/billing",   icon: "💳", gradient: "from-rose-500/10 to-pink-500/10",   border: "border-rose-500/20" },
  ];

  return (
    <div className="space-y-8 animate-fade-in">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">{org?.name ?? "Dashboard"}</h1>
          <p className="mt-0.5 text-sm text-slate-500">
            {org?.subdomain ? `${org.subdomain}.trackme.app` : "Loading organization…"}
          </p>
        </div>
        {org && (
          <span className={`badge ${statusColor[org.subscription_status] ?? "bg-slate-100 text-slate-600"}`}>
            <span className="h-1.5 w-1.5 rounded-full bg-current" />
            {org.subscription_status}
          </span>
        )}
      </div>

      {/* Metric cards */}
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        {metrics.map(({ label, value, sub, iconPath, gradient, border, iconColor }, i) => (
          <div key={label}
            className={`card animate-fade-up stagger-${i + 1} bg-gradient-to-br p-5 ${gradient} ${border} border`}>
            <div className="flex items-start justify-between">
              <div>
                <p className="text-xs font-semibold uppercase tracking-wide text-slate-500">{label}</p>
                <p className="mt-1.5 text-2xl font-bold capitalize text-slate-900">{value}</p>
                {sub && <p className="mt-0.5 text-xs capitalize text-slate-400">{sub}</p>}
              </div>
              <div className={`rounded-xl bg-white p-2.5 shadow-sm ${iconColor}`}>
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.75}
                  strokeLinecap="round" strokeLinejoin="round" className="h-5 w-5">
                  <path d={iconPath} />
                </svg>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Quick actions */}
      <div>
        <h2 className="mb-4 text-base font-semibold text-slate-700">Quick Actions</h2>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
          {quickLinks.map(({ label, desc, href, icon, gradient, border }) => (
            <Link key={href} href={href}
              className={`group card bg-gradient-to-br p-5 ${gradient} ${border} border flex items-start gap-4 no-underline`}>
              <span className="text-3xl">{icon}</span>
              <div>
                <p className="font-semibold text-slate-800 group-hover:text-rose-600 transition-colors">{label}</p>
                <p className="mt-0.5 text-xs text-slate-500">{desc}</p>
              </div>
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
}
