import type { Organization, SubscriptionTier } from "@/types";

interface CurrentPlanCardProps {
  org: Organization;
}

export default function CurrentPlanCard({ org }: CurrentPlanCardProps) {
  return (
    <div className="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
      <h2 className="text-base font-semibold text-gray-800">Current Plan</h2>
      <div className="mt-3 flex flex-wrap items-center gap-4">
        <span className="rounded-full bg-red-100 px-3 py-1 text-sm font-semibold uppercase text-red-700">
          {org.subscription_tier}
        </span>
        <span className="text-sm capitalize text-gray-600">
          {org.subscription_status}
        </span>
        {org.trial_ends_at && (
          <span className="text-sm text-orange-600">
            Trial ends {new Date(org.trial_ends_at).toLocaleDateString()}
          </span>
        )}
      </div>
    </div>
  );
}
