"use client";
import useSWR from "swr";
import { api } from "@/lib/api";
import type { Organization } from "@/types";
import CurrentPlanCard from "@/features/billing/components/CurrentPlanCard";
import PricingCard from "@/features/billing/components/PricingCard";

const fetcher = (url: string) => api.get(url).then((r) => r.data);

const TIERS = [
  {
    name: "Free",
    price: "$0/mo",
    features: ["10 users", "5 facilitators", "100 queries/mo", "Community support"],
    highlight: false,
  },
  {
    name: "Professional",
    price: "$299/mo",
    features: ["100 users", "25 facilitators", "2,500 queries/mo", "Email support"],
    highlight: true,
  },
  {
    name: "Enterprise",
    price: "$999/mo",
    features: ["Unlimited users", "Unlimited facilitators", "Unlimited queries", "24/7 priority support"],
    highlight: false,
  },
];

export default function BillingPage() {
  const { data: org } = useSWR<Organization>("/api/organizations/me", fetcher);

  return (
    <div>
      <h1 className="text-2xl font-bold text-gray-900">Billing</h1>
      <p className="mt-1 text-sm text-gray-500">Manage your subscription.</p>

      {org && (
        <div className="mt-6">
          <CurrentPlanCard org={org} />
        </div>
      )}

      <div className="mt-8 grid grid-cols-1 gap-6 sm:grid-cols-3">
        {TIERS.map((tier) => (
          <PricingCard
            key={tier.name}
            name={tier.name}
            price={tier.price}
            features={tier.features}
            highlight={tier.highlight}
            isCurrentPlan={
              org?.subscription_tier === tier.name.toLowerCase()
            }
          />
        ))}
      </div>
    </div>
  );
}
