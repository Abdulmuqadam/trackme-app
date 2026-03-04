import type { User } from "@/types";

export default function UserTable({ users }: { users: User[] }) {
  return (
    <table className="w-full text-sm">
      <thead>
        <tr className="border-b border-slate-100 bg-slate-50 text-left text-xs font-semibold uppercase tracking-wider text-slate-500">
          <th className="px-6 py-3.5">User</th>
          <th className="px-6 py-3.5">Email</th>
          <th className="px-6 py-3.5">Gender</th>
          <th className="px-6 py-3.5">Phone</th>
          <th className="px-6 py-3.5 text-right">Actions</th>
        </tr>
      </thead>
      <tbody className="divide-y divide-slate-100">
        {users.map((user) => (
          <tr key={user.id} className="group transition-colors hover:bg-slate-50">
            <td className="px-6 py-4">
              <div className="flex items-center gap-3">
                <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-gradient-to-br from-blue-400 to-indigo-500 text-xs font-bold text-white">
                  {user.firstname?.[0]?.toUpperCase()}{user.lastname?.[0]?.toUpperCase()}
                </div>
                <div>
                  <p className="font-medium text-slate-900">
                    {user.firstname} {user.lastname}
                  </p>
                  <p className="text-xs text-slate-400">#{user.id}</p>
                </div>
              </div>
            </td>
            <td className="px-6 py-4 text-slate-600">{user.email}</td>
            <td className="px-6 py-4">
              <span className="badge bg-slate-100 text-slate-600">{user.gender ?? "—"}</span>
            </td>
            <td className="px-6 py-4 font-mono text-xs text-slate-500">{user.number ?? "—"}</td>
            <td className="px-6 py-4 text-right">
              <button className="text-xs text-rose-500 opacity-0 transition-opacity group-hover:opacity-100 hover:underline">
                Deactivate
              </button>
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}
