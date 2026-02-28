import type { User } from "@/types";

interface UserTableProps {
  users: User[];
}

export default function UserTable({ users }: UserTableProps) {
  return (
    <table className="w-full text-sm">
      <thead className="bg-gray-50 text-left text-xs font-semibold uppercase text-gray-500">
        <tr>
          <th className="px-6 py-3">ID</th>
          <th className="px-6 py-3">Name</th>
          <th className="px-6 py-3">Email</th>
          <th className="px-6 py-3">Gender</th>
          <th className="px-6 py-3">Actions</th>
        </tr>
      </thead>
      <tbody className="divide-y divide-gray-100">
        {users.map((user) => (
          <tr key={user.id} className="hover:bg-gray-50">
            <td className="px-6 py-4 font-mono text-gray-500">{user.id}</td>
            <td className="px-6 py-4 font-medium">
              {user.firstname} {user.lastname}
            </td>
            <td className="px-6 py-4 text-gray-600">{user.email}</td>
            <td className="px-6 py-4 text-gray-600">{user.gender ?? "—"}</td>
            <td className="px-6 py-4">
              <button className="text-xs text-red-500 hover:underline">
                Deactivate
              </button>
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}
