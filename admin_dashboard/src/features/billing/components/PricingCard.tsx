import type { SubscriptionTier } from "@/types";

interface PricingCardProps {
  name: string;
  price: string;
  features: string[];
  highlight?: boolean;
  isCurrentPlan: boolean;
}

export default function PricingCard({
  name,
  price,
  features,
  highlight = false,
  isCurrentPlan,
}: PricingCardProps) {
  return (
    <div
      className={`rounded-xl border-2 bg-white p-6 shadow-sm ${
        highlight ? "border-red-500 ring-2 ring-red-500" : "border-gray-200"
      }`}
    >
      {highlight && (
        <span className="mb-3 inline-block rounded-full bg-red-600 px-2 py-0.5 text-xs font-bold text-white">
          POPULAR
        </span>
      )}
      <h3 className="text-lg font-bold text-gray-900">{name}</h3>
      <p className="mt-1 text-3xl font-extrabold text-gray-900">{price}</p>
      <ul className="mt-4 space-y-2">
        {features.map((f) => (
          <li key={f} className="flex items-center gap-2 text-sm text-gray-600">
            <span className="text-green-500">✓</span> {f}
          </li>
        ))}
      </ul>
      <button
        className={`mt-6 w-full rounded-lg py-2 text-sm font-semibold ${
          highlight
            ? "bg-red-600 text-white hover:bg-red-700"
            : "border border-gray-300 text-gray-700 hover:bg-gray-50"
        }`}
      >
        {isCurrentPlan ? "Current Plan" : "Upgrade"}
      </button>
    </div>
  );
}
