"use client";
import useSWR from "swr";
import { api } from "@/lib/api";
import type { Facilitator } from "@/types";
import FacilitatorTable from "@/features/facilitators/components/FacilitatorTable";

const fetcher = (url: string) => api.get(url).then((r) => r.data);

function Skeleton() {
  return (
    <div className="space-y-3 p-6">
      {[...Array(5)].map((_, i) => (
        <div key={i} className="h-10 animate-pulse rounded-lg bg-slate-100" />
      ))}
    </div>
  );
}

const roleColors: Record<string, string> = {
  Police:          "bg-blue-100 text-blue-700",
  Ambulance:       "bg-red-100 text-red-700",
  "Road Assistance": "bg-amber-100 text-amber-700",
  Rescue:          "bg-emerald-100 text-emerald-700",
};

export default function FacilitatorsPage() {
  const { data, error, isLoading } = useSWR<Facilitator[]>("/api/facilitators", fetcher);
  const count = data?.length ?? 0;

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Facilitators</h1>
          <p className="mt-0.5 text-sm text-slate-500">
            {isLoading ? "Loading…" : `${count} response agent${count !== 1 ? "s" : ""}`}
          </p>
        </div>
      </div>

      {/* Role distribution pills */}
      {data && data.length > 0 && (
        <div className="flex flex-wrap gap-2">
          {Object.entries(
            data.reduce<Record<string, number>>((acc, f) => {
              acc[f.role] = (acc[f.role] || 0) + 1;
              return acc;
            }, {})
          ).map(([role, n]) => (
            <span key={role} className={`badge ${roleColors[role] ?? "bg-slate-100 text-slate-600"}`}>
              {role} · {n}
            </span>
          ))}
        </div>
      )}

      <div className="card overflow-hidden">
        {isLoading && <Skeleton />}
        {error && (
          <div className="flex items-center gap-3 p-6 text-sm text-rose-600">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" className="h-5 w-5">
              <circle cx="12" cy="12" r="10" /><path d="M12 8v4M12 16h.01" />
            </svg>
            Failed to load facilitators.
          </div>
        )}
        {data && <FacilitatorTable facilitators={data} />}
      </div>
    </div>
  );
}
