"use client";
import DashboardLayout from "@/components/DashboardLayout";
import useSWR from "swr";
import { api } from "@/lib/api";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  PieChart,
  Pie,
  Cell,
  ResponsiveContainer,
  Legend,
} from "recharts";

const fetcher = (url: string) => api.get(url).then((r) => r.data);

const COLORS = ["#ef4444", "#3b82f6", "#22c55e", "#f59e0b"];

export default function AnalyticsPage() {
  const { data: queries } = useSWR("/api/queries", fetcher, {
    refreshInterval: 30000,
  });

  // Build pie chart data from query types
  const queryTypeCount: Record<string, number> = {};
  if (Array.isArray(queries)) {
    queries.forEach((q: any) => {
      const t = q.querytype ?? "Unknown";
      queryTypeCount[t] = (queryTypeCount[t] || 0) + 1;
    });
  }
  const pieData = Object.entries(queryTypeCount).map(([name, value]) => ({
    name,
    value,
  }));

  // Build daily line chart (last 7 days) – single pass O(n)
  const now = new Date();
  const days: { date: string; count: number }[] = Array.from({ length: 7 }).map(
    (_, i) => {
      const d = new Date(now);
      d.setDate(d.getDate() - (6 - i));
      return { date: d.toLocaleDateString("en-US", { weekday: "short" }), count: 0 };
    }
  );
  if (Array.isArray(queries)) {
    // Build a map from date string → day index for O(1) lookup
    const dayKeyMap = new Map<string, number>();
    days.forEach((day, idx) => {
      const d = new Date(now);
      d.setDate(d.getDate() - (6 - idx));
      dayKeyMap.set(d.toDateString(), idx);
    });

    queries.forEach((q: any) => {
      const idx = dayKeyMap.get(new Date(q.createdAt).toDateString());
      if (idx !== undefined) {
        days[idx].count += 1;
      }
    });
  }

  const totalQueries = Array.isArray(queries) ? queries.length : 0;
  const completedQueries = Array.isArray(queries)
    ? queries.filter((q: any) => q.completed).length
    : 0;
  const resolutionRate = totalQueries > 0
    ? Math.round((completedQueries / totalQueries) * 100)
    : 0;

  return (
    <DashboardLayout>
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Analytics</h1>
        <p className="mt-1 text-sm text-gray-500">Query performance and trends.</p>

        {/* Summary stats */}
        <div className="mt-6 grid grid-cols-3 gap-6">
          {[
            { label: "Total Queries", value: totalQueries },
            { label: "Completed", value: completedQueries },
            { label: "Resolution Rate", value: `${resolutionRate}%` },
          ].map((s) => (
            <div key={s.label} className="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
              <p className="text-sm text-gray-500">{s.label}</p>
              <p className="mt-1 text-3xl font-bold text-gray-900">{s.value}</p>
            </div>
          ))}
        </div>

        {/* Charts */}
        <div className="mt-8 grid grid-cols-1 gap-8 lg:grid-cols-2">
          {/* Line chart */}
          <div className="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
            <h2 className="mb-4 text-base font-semibold text-gray-800">Queries – Last 7 Days</h2>
            <ResponsiveContainer width="100%" height={240}>
              <LineChart data={days}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="date" />
                <YAxis allowDecimals={false} />
                <Tooltip />
                <Line type="monotone" dataKey="count" stroke="#ef4444" strokeWidth={2} dot={false} />
              </LineChart>
            </ResponsiveContainer>
          </div>

          {/* Pie chart */}
          <div className="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
            <h2 className="mb-4 text-base font-semibold text-gray-800">Query Types</h2>
            <ResponsiveContainer width="100%" height={240}>
              <PieChart>
                <Pie data={pieData} cx="50%" cy="50%" outerRadius={80} dataKey="value" label>
                  {pieData.map((_, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Legend />
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}
