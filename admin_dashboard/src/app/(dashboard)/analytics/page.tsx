"use client";
import useSWR from "swr";
import { api } from "@/lib/api";
import type { Query } from "@/types";
import QueryTrendChart from "@/features/analytics/components/QueryTrendChart";
import QueryTypePieChart from "@/features/analytics/components/QueryTypePieChart";
import SummaryCards from "@/features/analytics/components/SummaryCards";

const fetcher = (url: string) => api.get(url).then((r) => r.data);

export default function AnalyticsPage() {
  const { data: queries } = useSWR<Query[]>("/api/queries", fetcher, {
    refreshInterval: 30000,
  });

  const queryList = Array.isArray(queries) ? queries : [];

  // Pie chart data
  const queryTypeCount: Record<string, number> = {};
  queryList.forEach((q) => {
    const t = q.querytype ?? "Unknown";
    queryTypeCount[t] = (queryTypeCount[t] || 0) + 1;
  });
  const pieData = Object.entries(queryTypeCount).map(([name, value]) => ({
    name,
    value,
  }));

  // Line chart – last 7 days, O(n) with date-key map
  const now = new Date();
  const days = Array.from({ length: 7 }).map((_, i) => {
    const d = new Date(now);
    d.setDate(d.getDate() - (6 - i));
    return { date: d.toLocaleDateString("en-US", { weekday: "short" }), count: 0, _key: d.toDateString() };
  });
  const dayKeyMap = new Map(days.map((d, idx) => [d._key, idx]));
  queryList.forEach((q) => {
    const idx = dayKeyMap.get(new Date(q.createdAt!).toDateString());
    if (idx !== undefined) days[idx].count += 1;
  });

  const totalQueries = queryList.length;
  const completedQueries = queryList.filter((q) => q.completed).length;
  const resolutionRate =
    totalQueries > 0 ? Math.round((completedQueries / totalQueries) * 100) : 0;

  return (
    <div>
      <h1 className="text-2xl font-bold text-gray-900">Analytics</h1>
      <p className="mt-1 text-sm text-gray-500">Query performance and trends.</p>

      <div className="mt-6">
        <SummaryCards
          total={totalQueries}
          completed={completedQueries}
          resolutionRate={resolutionRate}
        />
      </div>

      <div className="mt-8 grid grid-cols-1 gap-8 lg:grid-cols-2">
        <QueryTrendChart data={days} />
        <QueryTypePieChart data={pieData} />
      </div>
    </div>
  );
}
