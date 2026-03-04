"use client";
import {
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
} from "recharts";

interface DayCount { date: string; count: number; }

export default function QueryTrendChart({ data }: { data: DayCount[] }) {
  return (
    <div className="card p-6">
      <div className="mb-5 flex items-center justify-between">
        <div>
          <h2 className="text-sm font-semibold text-slate-800">Query Volume</h2>
          <p className="text-xs text-slate-400">Last 7 days</p>
        </div>
        <span className="badge bg-blue-50 text-blue-600">Weekly</span>
      </div>
      <ResponsiveContainer width="100%" height={220}>
        <AreaChart data={data} margin={{ top: 4, right: 4, left: -20, bottom: 0 }}>
          <defs>
            <linearGradient id="countGrad" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%"  stopColor="#f43f5e" stopOpacity={0.18} />
              <stop offset="95%" stopColor="#f43f5e" stopOpacity={0} />
            </linearGradient>
          </defs>
          <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" vertical={false} />
          <XAxis dataKey="date" tick={{ fontSize: 11, fill: "#94a3b8" }} axisLine={false} tickLine={false} />
          <YAxis allowDecimals={false} tick={{ fontSize: 11, fill: "#94a3b8" }} axisLine={false} tickLine={false} />
          <Tooltip
            contentStyle={{ background: "#1e293b", border: "none", borderRadius: "0.75rem", color: "#f1f5f9", fontSize: 12 }}
            cursor={{ stroke: "#f43f5e", strokeWidth: 1, strokeDasharray: "4 2" }}
          />
          <Area type="monotone" dataKey="count" stroke="#f43f5e" strokeWidth={2.5}
            fill="url(#countGrad)" dot={false} activeDot={{ r: 5, fill: "#f43f5e" }} />
        </AreaChart>
      </ResponsiveContainer>
    </div>
  );
}
