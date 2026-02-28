import type { Facilitator } from "@/types";

interface FacilitatorTableProps {
  facilitators: Facilitator[];
}

export default function FacilitatorTable({ facilitators }: FacilitatorTableProps) {
  return (
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
        {facilitators.map((f) => (
          <tr key={f.id} className="hover:bg-gray-50">
            <td className="px-6 py-4 font-mono text-gray-500">{f.id}</td>
            <td className="px-6 py-4 font-medium">
              {f.firstname} {f.lastname}
            </td>
            <td className="px-6 py-4 text-gray-600">{f.email}</td>
            <td className="px-6 py-4">
              <span className="rounded-full bg-blue-100 px-2 py-0.5 text-xs font-medium text-blue-700">
                {f.role}
              </span>
            </td>
            <td className="px-6 py-4 font-mono text-xs text-gray-500">
              {f.location ?? "—"}
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}
