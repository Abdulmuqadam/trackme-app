"use client";
import DashboardLayout from "@/components/DashboardLayout";
import useSWR from "swr";
import { api } from "@/lib/api";

const fetcher = (url: string) => api.get(url).then((r) => r.data);

interface StatCardProps {
  label: string;
  value: string | number;
  icon: string;
  color: string;
}

function StatCard({ label, value, icon, color }: StatCardProps) {
  return (
    <div className={`rounded-xl border border-gray-200 bg-white p-6 shadow-sm`}>
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm text-gray-500">{label}</p>
          <p className="mt-1 text-3xl font-bold text-gray-900">{value}</p>
        </div>
        <span className={`text-4xl ${color}`}>{icon}</span>
      </div>
    </div>
  );
}

export default function DashboardPage() {
  const { data: orgData } = useSWR("/api/organizations/me", fetcher, {
    refreshInterval: 30000,
  });

  return (
    <DashboardLayout>
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-sm text-gray-500">
          {orgData?.name ?? "Loading organization..."}
        </p>

        {/* Subscription badge */}
        {orgData && (
          <div className="mt-2 inline-flex items-center gap-2 rounded-full bg-green-100 px-3 py-1 text-xs font-medium text-green-800">
            <span className="h-2 w-2 rounded-full bg-green-500" />
            {orgData.subscription_tier} · {orgData.subscription_status}
          </div>
        )}

        {/* Stats */}
        <div className="mt-8 grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
          <StatCard label="Plan" value={orgData?.subscription_tier ?? "—"} icon="💎" color="text-blue-500" />
          <StatCard label="Max Users" value={orgData?.max_users ?? "—"} icon="👥" color="text-green-500" />
          <StatCard label="Max Facilitators" value={orgData?.max_facilitators ?? "—"} icon="🚨" color="text-red-500" />
          <StatCard
            label="Trial Ends"
            value={orgData?.trial_ends_at ? new Date(orgData.trial_ends_at).toLocaleDateString() : "—"}
            icon="📅"
            color="text-orange-500"
          />
        </div>

        {/* Quick links */}
        <div className="mt-10">
          <h2 className="mb-4 text-lg font-semibold text-gray-800">Quick Actions</h2>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
            {[
              { label: "Manage Users", href: "/dashboard/users", icon: "👥" },
              { label: "View Analytics", href: "/dashboard/analytics", icon: "📈" },
              { label: "Billing", href: "/dashboard/billing", icon: "💳" },
            ].map((action) => (
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
    </DashboardLayout>
  );
}
