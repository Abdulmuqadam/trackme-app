"use client";
import useSWR from "swr";
import { api } from "@/lib/api";
import type { Organization } from "@/types";

const fetcher = (url: string) => api.get(url).then((r) => r.data);

const TIERS = [
  {
    name: "Free",
    price: "$0",
    period: "/month",
    features: ["10 users", "5 facilitators", "100 queries/mo", "Community support"],
    highlight: false,
    tier: "free",
  },
  {
    name: "Professional",
    price: "$299",
    period: "/month",
    features: ["100 users", "25 facilitators", "2,500 queries/mo", "Email support", "Analytics"],
    highlight: true,
    tier: "professional",
  },
  {
    name: "Enterprise",
    price: "$999",
    period: "/month",
    features: ["Unlimited users", "Unlimited facilitators", "Unlimited queries", "24/7 priority support", "Custom SLA"],
    highlight: false,
    tier: "enterprise",
  },
];

export default function BillingPage() {
  const { data: org } = useSWR<Organization>("/api/organizations/me", fetcher);

  return (
    <div className="space-y-8 animate-fade-in">
      <div>
        <h1 className="text-2xl font-bold text-slate-900">Billing</h1>
        <p className="mt-0.5 text-sm text-slate-500">Manage your subscription and plan.</p>
      </div>

      {/* Current plan banner */}
      {org && (
        <div className="card flex flex-wrap items-center justify-between gap-4 p-5"
          style={{ background: "linear-gradient(135deg, #0f172a 0%, #1e1b4b 100%)" }}>
          <div>
            <p className="text-xs font-semibold uppercase tracking-wide text-slate-400">Current Plan</p>
            <p className="mt-1 text-xl font-bold capitalize text-white">{org.subscription_tier}</p>
            {org.trial_ends_at && (
              <p className="mt-0.5 text-xs text-amber-400">
                Trial ends {new Date(org.trial_ends_at).toLocaleDateString()}
              </p>
            )}
          </div>
          <div className="flex items-center gap-2">
            <span className="rounded-full bg-emerald-400/15 px-3 py-1 text-xs font-semibold capitalize text-emerald-400">
              {org.subscription_status}
            </span>
          </div>
        </div>
      )}

      {/* Pricing grid */}
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-3">
        {TIERS.map(({ name, price, period, features, highlight, tier }) => {
          const isCurrent = org?.subscription_tier === tier;
          return (
            <div key={name}
              className={`card flex flex-col p-6 ${highlight ? "ring-2 ring-rose-500" : ""} ${isCurrent ? "ring-2 ring-emerald-500" : ""}`}>
              {highlight && !isCurrent && (
                <span className="mb-3 self-start rounded-full bg-rose-600 px-2.5 py-0.5 text-xs font-bold text-white uppercase tracking-wider">
                  Popular
                </span>
              )}
              {isCurrent && (
                <span className="mb-3 self-start rounded-full bg-emerald-600 px-2.5 py-0.5 text-xs font-bold text-white uppercase tracking-wider">
                  Current
                </span>
              )}
              <h3 className="text-lg font-bold text-slate-900">{name}</h3>
              <div className="mt-2 flex items-end gap-1">
                <span className="text-4xl font-extrabold text-slate-900">{price}</span>
                <span className="mb-1 text-sm text-slate-400">{period}</span>
              </div>
              <ul className="mt-5 flex-1 space-y-2.5">
                {features.map((f) => (
                  <li key={f} className="flex items-center gap-2 text-sm text-slate-600">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2.5}
                      className="h-4 w-4 shrink-0 text-emerald-500">
                      <path d="M20 6L9 17l-5-5" />
                    </svg>
                    {f}
                  </li>
                ))}
              </ul>
              <button
                className={`mt-6 w-full rounded-[0.625rem] py-2.5 text-sm font-semibold transition-all ${
                  isCurrent
                    ? "cursor-default bg-slate-100 text-slate-400"
                    : highlight
                    ? "text-white hover:-translate-y-0.5 hover:shadow-lg"
                    : "border border-slate-200 text-slate-700 hover:border-rose-300 hover:text-rose-600"
                }`}
                style={!isCurrent && highlight ? { background: "linear-gradient(135deg,#f43f5e,#be123c)" } : undefined}
              >
                {isCurrent ? "Current Plan" : `Upgrade to ${name}`}
              </button>
            </div>
          );
        })}
      </div>
    </div>
  );
}
