"use client";
import useSWR from "swr";
import { api } from "@/lib/api";
import type { Query } from "@/types";
import QueryTrendChart from "@/features/analytics/components/QueryTrendChart";
import QueryTypePieChart from "@/features/analytics/components/QueryTypePieChart";

const fetcher = (url: string) => api.get(url).then((r) => r.data);

export default function AnalyticsPage() {
  const { data: queries, isLoading } = useSWR<Query[]>("/api/queries", fetcher, {
    refreshInterval: 30000,
  });

  const queryList = Array.isArray(queries) ? queries : [];

  const totalQueries    = queryList.length;
  const completedQueries = queryList.filter((q) => q.completed).length;
  const openQueries     = totalQueries - completedQueries;
  const resolutionRate  = totalQueries > 0 ? Math.round((completedQueries / totalQueries) * 100) : 0;

  // Pie chart data
  const queryTypeCount: Record<string, number> = {};
  queryList.forEach((q) => {
    const t = q.querytype ?? "Unknown";
    queryTypeCount[t] = (queryTypeCount[t] || 0) + 1;
  });
  const pieData = Object.entries(queryTypeCount).map(([name, value]) => ({ name, value }));

  // 7-day trend
  const now = new Date();
  const days = Array.from({ length: 7 }).map((_, i) => {
    const d = new Date(now);
    d.setDate(d.getDate() - (6 - i));
    return { date: d.toLocaleDateString("en-US", { weekday: "short" }), count: 0, _key: d.toDateString() };
  });
  const dayKeyMap = new Map(days.map((d, idx) => [d._key, idx]));
  queryList.forEach((q) => {
    if (!q.createdAt) return;
    const idx = dayKeyMap.get(new Date(q.createdAt).toDateString());
    if (idx !== undefined) days[idx].count += 1;
  });

  const summaryCards = [
    { label: "Total Queries",    value: totalQueries,     color: "text-slate-900",  bg: "bg-slate-50" },
    { label: "Completed",        value: completedQueries, color: "text-emerald-600",bg: "bg-emerald-50" },
    { label: "Open",             value: openQueries,      color: "text-amber-600",  bg: "bg-amber-50" },
    { label: "Resolution Rate",  value: `${resolutionRate}%`, color: "text-blue-600", bg: "bg-blue-50" },
  ];

  return (
    <div className="space-y-8 animate-fade-in">
      <div>
        <h1 className="text-2xl font-bold text-slate-900">Analytics</h1>
        <p className="mt-0.5 text-sm text-slate-500">Query performance and incident trends</p>
      </div>

      {/* Summary */}
      <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
        {summaryCards.map(({ label, value, color, bg }, i) => (
          <div key={label} className={`card animate-fade-up stagger-${i + 1} p-5 ${bg}`}>
            <p className="text-xs font-semibold uppercase tracking-wide text-slate-500">{label}</p>
            <p className={`mt-1.5 text-3xl font-extrabold ${color}`}>{isLoading ? "—" : value}</p>
          </div>
        ))}
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        <QueryTrendChart data={days} />
        <QueryTypePieChart data={pieData} />
      </div>
    </div>
  );
}
