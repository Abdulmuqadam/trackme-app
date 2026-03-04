"use client";
import { PieChart, Pie, Cell, Legend, Tooltip, ResponsiveContainer } from "recharts";

const COLORS = ["#f43f5e", "#3b82f6", "#10b981", "#f59e0b", "#8b5cf6"];

interface PieEntry { name: string; value: number; }

export default function QueryTypePieChart({ data }: { data: PieEntry[] }) {
  return (
    <div className="card p-6">
      <div className="mb-5">
        <h2 className="text-sm font-semibold text-slate-800">Query Types</h2>
        <p className="text-xs text-slate-400">Distribution by category</p>
      </div>
      {data.length === 0 ? (
        <div className="flex h-[220px] items-center justify-center text-sm text-slate-400">
          No data available
        </div>
      ) : (
        <ResponsiveContainer width="100%" height={220}>
          <PieChart>
            <Pie data={data} cx="50%" cy="45%" outerRadius={80} innerRadius={45} dataKey="value"
              paddingAngle={3}>
              {data.map((_, index) => (
                <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} stroke="none" />
              ))}
            </Pie>
            <Legend
              iconType="circle"
              iconSize={8}
              formatter={(value) => <span style={{ fontSize: 11, color: "#64748b" }}>{value}</span>}
            />
            <Tooltip
              contentStyle={{ background: "#1e293b", border: "none", borderRadius: "0.75rem", color: "#f1f5f9", fontSize: 12 }}
            />
          </PieChart>
        </ResponsiveContainer>
      )}
    </div>
  );
}
