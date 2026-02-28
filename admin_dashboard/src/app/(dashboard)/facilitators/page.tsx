"use client";
import useSWR from "swr";
import { api } from "@/lib/api";
import type { Facilitator } from "@/types";
import FacilitatorTable from "@/features/facilitators/components/FacilitatorTable";
import LoadingSpinner from "@/components/ui/LoadingSpinner";

const fetcher = (url: string) => api.get(url).then((r) => r.data);

export default function FacilitatorsPage() {
  const { data, error, isLoading } = useSWR<Facilitator[]>("/api/facilitators", fetcher);

  return (
    <div>
      <h1 className="text-2xl font-bold text-gray-900">Facilitators</h1>
      <p className="mt-1 text-sm text-gray-500">
        Manage responders assigned to your organization.
      </p>

      <div className="mt-6 overflow-hidden rounded-xl border border-gray-200 bg-white shadow-sm">
        {isLoading && <LoadingSpinner />}
        {error && (
          <p className="p-6 text-sm text-red-600">Failed to load facilitators.</p>
        )}
        {data && <FacilitatorTable facilitators={data} />}
      </div>
    </div>
  );
}
