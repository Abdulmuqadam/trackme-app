"use client";
import DashboardLayout from "@/components/DashboardLayout";
import useSWR from "swr";
import { api } from "@/lib/api";

const fetcher = (url: string) => api.get(url).then((r) => r.data);

export default function FacilitatorsPage() {
  const { data, error, isLoading } = useSWR("/api/facilitators", fetcher);

  return (
    <DashboardLayout>
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Facilitators</h1>
        <p className="mt-1 text-sm text-gray-500">Manage responders assigned to your organization.</p>

        <div className="mt-6 overflow-hidden rounded-xl border border-gray-200 bg-white shadow-sm">
          {isLoading && (
            <div className="flex h-48 items-center justify-center">
              <div className="h-8 w-8 animate-spin rounded-full border-4 border-red-600 border-t-transparent" />
            </div>
          )}
          {error && (
            <p className="p-6 text-sm text-red-600">Failed to load facilitators.</p>
          )}
          {data && (
            <table className="w-full text-sm">
              <thead className="bg-gray-50 text-left text-xs font-semibold uppercase text-gray-500">
                <tr>
                  <th className="px-6 py-3">ID</th>
                  <th className="px-6 py-3">Name</th>
                  <th className="px-6 py-3">Email</th>
                  <th className="px-6 py-3">Role</th>
                  <th className="px-6 py-3">Location</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {Array.isArray(data) && data.map((f: any) => (
                  <tr key={f.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 font-mono text-gray-500">{f.id}</td>
                    <td className="px-6 py-4 font-medium">{f.firstname} {f.lastname}</td>
                    <td className="px-6 py-4 text-gray-600">{f.email}</td>
                    <td className="px-6 py-4">
                      <span className="rounded-full bg-blue-100 px-2 py-0.5 text-xs font-medium text-blue-700">
                        {f.role}
                      </span>
                    </td>
                    <td className="px-6 py-4 font-mono text-xs text-gray-500">{f.location ?? "—"}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>
    </DashboardLayout>
  );
}
