"use client";
import DashboardLayout from "@/components/DashboardLayout";
import useSWR from "swr";
import { api } from "@/lib/api";

const fetcher = (url: string) => api.get(url).then((r) => r.data);

const TIERS = [
  {
    name: "Free",
    price: "$0/mo",
    features: ["10 users", "5 facilitators", "100 queries/mo", "Community support"],
    color: "border-gray-200",
  },
  {
    name: "Professional",
    price: "$299/mo",
    features: ["100 users", "25 facilitators", "2,500 queries/mo", "Email support"],
    color: "border-red-500",
    highlight: true,
  },
  {
    name: "Enterprise",
    price: "$999/mo",
    features: ["Unlimited users", "Unlimited facilitators", "Unlimited queries", "24/7 priority support"],
    color: "border-gray-200",
  },
];

export default function BillingPage() {
  const { data: org } = useSWR("/api/organizations/me", fetcher);

  return (
    <DashboardLayout>
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Billing</h1>
        <p className="mt-1 text-sm text-gray-500">Manage your subscription.</p>

        {/* Current plan */}
        {org && (
          <div className="mt-6 rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
            <h2 className="text-base font-semibold text-gray-800">Current Plan</h2>
            <div className="mt-3 flex items-center gap-4">
              <span className="rounded-full bg-red-100 px-3 py-1 text-sm font-semibold text-red-700 uppercase">
                {org.subscription_tier}
              </span>
              <span className="text-sm text-gray-600 capitalize">{org.subscription_status}</span>
              {org.trial_ends_at && (
                <span className="text-sm text-orange-600">
                  Trial ends {new Date(org.trial_ends_at).toLocaleDateString()}
                </span>
              )}
            </div>
          </div>
        )}

        {/* Pricing tiers */}
        <div className="mt-8 grid grid-cols-1 gap-6 sm:grid-cols-3">
          {TIERS.map((tier) => (
            <div
              key={tier.name}
              className={`rounded-xl border-2 bg-white p-6 shadow-sm ${tier.color} ${
                tier.highlight ? "ring-2 ring-red-500" : ""
              }`}
            >
              {tier.highlight && (
                <span className="mb-3 inline-block rounded-full bg-red-600 px-2 py-0.5 text-xs font-bold text-white">
                  POPULAR
                </span>
              )}
              <h3 className="text-lg font-bold text-gray-900">{tier.name}</h3>
              <p className="mt-1 text-3xl font-extrabold text-gray-900">{tier.price}</p>
              <ul className="mt-4 space-y-2">
                {tier.features.map((f) => (
                  <li key={f} className="flex items-center gap-2 text-sm text-gray-600">
                    <span className="text-green-500">✓</span> {f}
                  </li>
                ))}
              </ul>
              <button
                className={`mt-6 w-full rounded-lg py-2 text-sm font-semibold ${
                  tier.highlight
                    ? "bg-red-600 text-white hover:bg-red-700"
                    : "border border-gray-300 text-gray-700 hover:bg-gray-50"
                }`}
              >
                {org?.subscription_tier === tier.name.toLowerCase() ? "Current Plan" : "Upgrade"}
              </button>
            </div>
          ))}
        </div>
      </div>
    </DashboardLayout>
  );
}
