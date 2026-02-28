"use client";
import useSWR from "swr";
import { api } from "@/lib/api";
import type { User } from "@/types";
import UserTable from "@/features/users/components/UserTable";
import LoadingSpinner from "@/components/ui/LoadingSpinner";

const fetcher = (url: string) => api.get(url).then((r) => r.data);

export default function UsersPage() {
  const { data, error, isLoading } = useSWR<User[]>("/api/users", fetcher);

  return (
    <div>
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900">Users</h1>
        <button className="rounded-lg bg-red-600 px-4 py-2 text-sm font-semibold text-white hover:bg-red-700">
          + Invite User
        </button>
      </div>

      <div className="mt-6 overflow-hidden rounded-xl border border-gray-200 bg-white shadow-sm">
        {isLoading && <LoadingSpinner />}
        {error && <p className="p-6 text-sm text-red-600">Failed to load users.</p>}
        {data && <UserTable users={data} />}
      </div>
    </div>
  );
}
