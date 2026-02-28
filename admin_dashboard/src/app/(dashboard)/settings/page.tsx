"use client";
import useSWR from "swr";
import { api } from "@/lib/api";
import type { Organization } from "@/types";

const fetcher = (url: string) => api.get(url).then((r) => r.data);

export default function SettingsPage() {
  const { data: org } = useSWR<Organization>("/api/organizations/me", fetcher);

  return (
    <div className="max-w-2xl">
      <h1 className="text-2xl font-bold text-gray-900">Settings</h1>
      <p className="mt-1 text-sm text-gray-500">Organization configuration.</p>

      <div className="mt-6 rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
        <h2 className="text-base font-semibold text-gray-800">
          Organization Details
        </h2>
        <div className="mt-4 space-y-4">
          <div>
            <label className="mb-1 block text-sm font-medium text-gray-600">
              Organization Name
            </label>
            <input
              type="text"
              defaultValue={org?.name ?? ""}
              className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-red-500 focus:outline-none"
            />
          </div>
          <div>
            <label className="mb-1 block text-sm font-medium text-gray-600">
              Subdomain
            </label>
            <div className="flex items-center gap-2">
              <input
                type="text"
                defaultValue={org?.subdomain ?? ""}
                className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-red-500 focus:outline-none"
              />
              <span className="text-sm text-gray-500">.trackme.app</span>
            </div>
          </div>
        </div>
        <button className="mt-6 rounded-lg bg-red-600 px-4 py-2 text-sm font-semibold text-white hover:bg-red-700">
          Save Changes
        </button>
      </div>

      {org?.api_key && (
        <div className="mt-6 rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
          <h2 className="text-base font-semibold text-gray-800">API Key</h2>
          <p className="mt-1 text-xs text-gray-500">
            Use this key in the{" "}
            <code className="font-mono text-red-600">X-API-Key</code> header
            for mobile/API access.
          </p>
          <div className="mt-3 flex items-center gap-2">
            <code className="flex-1 select-all rounded-lg bg-gray-100 px-3 py-2 font-mono text-xs text-gray-700">
              {org.api_key}
            </code>
            <button
              onClick={() => navigator.clipboard.writeText(org.api_key!)}
              className="rounded-lg border border-gray-300 px-3 py-2 text-xs font-medium hover:bg-gray-50"
            >
              Copy
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
