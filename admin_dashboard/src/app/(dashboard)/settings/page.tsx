"use client";
import useSWR from "swr";
import { useState } from "react";
import { api } from "@/lib/api";
import type { Organization } from "@/types";

const fetcher = (url: string) => api.get(url).then((r) => r.data);

function SectionCard({ title, desc, children }: { title: string; desc?: string; children: React.ReactNode }) {
  return (
    <div className="card p-6">
      <div className="mb-5 border-b border-slate-100 pb-4">
        <h2 className="font-semibold text-slate-900">{title}</h2>
        {desc && <p className="mt-0.5 text-xs text-slate-500">{desc}</p>}
      </div>
      {children}
    </div>
  );
}

export default function SettingsPage() {
  const { data: org } = useSWR<Organization>("/api/organizations/me", fetcher);
  const [copied, setCopied] = useState(false);

  const copyKey = () => {
    if (org?.api_key) {
      navigator.clipboard.writeText(org.api_key);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    }
  };

  return (
    <div className="max-w-2xl space-y-6 animate-fade-in">
      <div>
        <h1 className="text-2xl font-bold text-slate-900">Settings</h1>
        <p className="mt-0.5 text-sm text-slate-500">Manage your organization configuration.</p>
      </div>

      <SectionCard title="Organization Details" desc="Update your organization's public information.">
        <div className="space-y-4">
          <div>
            <label className="mb-1.5 block text-xs font-semibold uppercase tracking-wide text-slate-500">
              Organization Name
            </label>
            <input
              type="text"
              defaultValue={org?.name ?? ""}
              className="input-base"
              placeholder="Organization name"
            />
          </div>
          <div>
            <label className="mb-1.5 block text-xs font-semibold uppercase tracking-wide text-slate-500">
              Subdomain
            </label>
            <div className="flex overflow-hidden rounded-[0.625rem] border-1.5 border-slate-200 bg-slate-50 focus-within:border-rose-500 focus-within:ring-3 focus-within:ring-rose-500/12">
              <input
                type="text"
                defaultValue={org?.subdomain ?? ""}
                className="flex-1 bg-transparent px-3.5 py-2.5 text-sm text-slate-900 outline-none"
              />
              <span className="flex items-center bg-slate-100 px-3 text-xs text-slate-500 border-l border-slate-200">
                .trackme.app
              </span>
            </div>
          </div>
          <button className="rounded-[0.625rem] px-5 py-2.5 text-sm font-semibold text-white transition-all hover:-translate-y-0.5"
            style={{ background: "linear-gradient(135deg,#f43f5e,#be123c)" }}>
            Save Changes
          </button>
        </div>
      </SectionCard>

      {org?.api_key && (
        <SectionCard
          title="API Key"
          desc="Use this key in the X-API-Key header for mobile and API clients.">
          <div className="flex items-center gap-3">
            <code className="flex-1 select-all overflow-hidden text-ellipsis rounded-xl bg-slate-50 border border-slate-200 px-4 py-3 font-mono text-xs text-slate-700">
              {org.api_key}
            </code>
            <button onClick={copyKey}
              className={`shrink-0 rounded-[0.625rem] px-4 py-2.5 text-xs font-semibold transition-all ${
                copied
                  ? "bg-emerald-100 text-emerald-700"
                  : "border border-slate-200 text-slate-600 hover:border-rose-300 hover:text-rose-600"
              }`}>
              {copied ? "✓ Copied" : "Copy"}
            </button>
          </div>
          <p className="mt-3 text-xs text-slate-400">
            Keep this key secret. Rotate it if you believe it has been compromised.
          </p>
        </SectionCard>
      )}

      <SectionCard title="Danger Zone" desc="Irreversible actions for your organization.">
        <button className="rounded-[0.625rem] border border-rose-200 px-5 py-2.5 text-sm font-semibold text-rose-600 transition-all hover:bg-rose-50">
          Delete Organization
        </button>
      </SectionCard>
    </div>
  );
}
