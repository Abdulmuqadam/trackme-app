"use client";
import useSWR from "swr";
import { api } from "@/lib/api";
import type { Organization } from "@/types";
import StatCard from "@/components/ui/StatCard";

const fetcher = (url: string) => api.get(url).then((r) => r.data);

const quickLinks = [
  { label: "Manage Users", href: "/dashboard/users", icon: "👥" },
  { label: "View Analytics", href: "/dashboard/analytics", icon: "📈" },
  { label: "Billing", href: "/dashboard/billing", icon: "💳" },
];

export default function DashboardPage() {
  const { data: org } = useSWR<Organization>("/api/organizations/me", fetcher, {
    refreshInterval: 30000,
  });

  return (
    <div>
      <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
      <p className="text-sm text-gray-500">{org?.name ?? "Loading…"}</p>

      {org && (
        <div className="mt-2 inline-flex items-center gap-2 rounded-full bg-green-100 px-3 py-1 text-xs font-medium text-green-800">
          <span className="h-2 w-2 rounded-full bg-green-500" />
          {org.subscription_tier} · {org.subscription_status}
        </div>
      )}

      <div className="mt-8 grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard label="Plan" value={org?.subscription_tier ?? "—"} icon="💎" />
        <StatCard label="Max Users" value={org?.max_users ?? "—"} icon="👥" />
        <StatCard label="Max Facilitators" value={org?.max_facilitators ?? "—"} icon="🚨" />
        <StatCard
          label="Trial Ends"
          value={org?.trial_ends_at ? new Date(org.trial_ends_at).toLocaleDateString() : "—"}
          icon="📅"
        />
      </div>

      <div className="mt-10">
        <h2 className="mb-4 text-lg font-semibold text-gray-800">Quick Actions</h2>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
          {quickLinks.map((action) => (
            <a
              key={action.href}
              href={action.href}
              className="flex items-center gap-3 rounded-xl border border-gray-200 bg-white p-4 shadow-sm transition hover:shadow-md"
            >
              <span className="text-2xl">{action.icon}</span>
              <span className="font-medium text-gray-700">{action.label}</span>
            </a>
          ))}
        </div>
      </div>
    </div>
  );
}
