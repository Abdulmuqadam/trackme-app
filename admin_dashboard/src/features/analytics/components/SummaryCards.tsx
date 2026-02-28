interface SummaryCardsProps {
  total: number;
  completed: number;
  resolutionRate: number;
}

export default function SummaryCards({
  total,
  completed,
  resolutionRate,
}: SummaryCardsProps) {
  const stats = [
    { label: "Total Queries", value: total },
    { label: "Completed", value: completed },
    { label: "Resolution Rate", value: `${resolutionRate}%` },
  ];
  return (
    <div className="grid grid-cols-3 gap-6">
      {stats.map((s) => (
        <div
          key={s.label}
          className="rounded-xl border border-gray-200 bg-white p-6 shadow-sm"
        >
          <p className="text-sm text-gray-500">{s.label}</p>
          <p className="mt-1 text-3xl font-bold text-gray-900">{s.value}</p>
        </div>
      ))}
    </div>
  );
}
