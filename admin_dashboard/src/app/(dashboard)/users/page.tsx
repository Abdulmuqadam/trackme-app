"use client";
import useSWR from "swr";
import { api } from "@/lib/api";
import type { User } from "@/types";
import UserTable from "@/features/users/components/UserTable";

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

export default function UsersPage() {
  const { data, error, isLoading } = useSWR<User[]>("/api/users", fetcher);
  const count = data?.length ?? 0;

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Users</h1>
          <p className="mt-0.5 text-sm text-slate-500">
            {isLoading ? "Loading…" : `${count} registered user${count !== 1 ? "s" : ""}`}
          </p>
        </div>
        <button className="flex items-center gap-2 rounded-[0.625rem] px-4 py-2 text-sm font-semibold text-white transition-all hover:-translate-y-0.5"
          style={{ background: "linear-gradient(135deg, #f43f5e, #be123c)" }}>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} className="h-4 w-4">
            <path d="M12 5v14M5 12h14" />
          </svg>
          Invite User
        </button>
      </div>

      <div className="card overflow-hidden">
        {isLoading && <Skeleton />}
        {error && (
          <div className="flex items-center gap-3 p-6 text-sm text-rose-600">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" className="h-5 w-5">
              <circle cx="12" cy="12" r="10" /><path d="M12 8v4M12 16h.01" />
            </svg>
            Failed to load users. Please try again.
          </div>
        )}
        {data && <UserTable users={data} />}
      </div>
    </div>
  );
}
