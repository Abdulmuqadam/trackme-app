import type { Facilitator } from "@/types";

const roleColors: Record<string, { bg: string; text: string }> = {
  Police:            { bg: "bg-blue-100",   text: "text-blue-700"   },
  Ambulance:         { bg: "bg-red-100",    text: "text-red-700"    },
  "Road Assistance": { bg: "bg-amber-100",  text: "text-amber-700"  },
  Rescue:            { bg: "bg-emerald-100",text: "text-emerald-700"},
};

export default function FacilitatorTable({ facilitators }: { facilitators: Facilitator[] }) {
  return (
    <table className="w-full text-sm">
      <thead>
        <tr className="border-b border-slate-100 bg-slate-50 text-left text-xs font-semibold uppercase tracking-wider text-slate-500">
          <th className="px-6 py-3.5">Facilitator</th>
          <th className="px-6 py-3.5">Email</th>
          <th className="px-6 py-3.5">Role</th>
          <th className="px-6 py-3.5">Location</th>
          <th className="px-6 py-3.5">Phone</th>
        </tr>
      </thead>
      <tbody className="divide-y divide-slate-100">
        {facilitators.map((f) => {
          const rc = roleColors[f.role] ?? { bg: "bg-slate-100", text: "text-slate-600" };
          return (
            <tr key={f.id} className="transition-colors hover:bg-slate-50">
              <td className="px-6 py-4">
                <div className="flex items-center gap-3">
                  <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-gradient-to-br from-rose-400 to-red-500 text-xs font-bold text-white">
                    {f.firstname?.[0]?.toUpperCase()}{f.lastname?.[0]?.toUpperCase()}
                  </div>
                  <div>
                    <p className="font-medium text-slate-900">{f.firstname} {f.lastname}</p>
                    <p className="text-xs text-slate-400">#{f.id}</p>
                  </div>
                </div>
              </td>
              <td className="px-6 py-4 text-slate-600">{f.email}</td>
              <td className="px-6 py-4">
                <span className={`badge ${rc.bg} ${rc.text}`}>{f.role}</span>
              </td>
              <td className="px-6 py-4 font-mono text-xs text-slate-400">{f.location ?? "—"}</td>
              <td className="px-6 py-4 font-mono text-xs text-slate-500">{f.number ?? "—"}</td>
            </tr>
          );
        })}
      </tbody>
    </table>
  );
}
