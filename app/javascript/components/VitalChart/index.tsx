import type { FC } from "react";
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ReferenceLine, ResponsiveContainer } from "recharts";
import type { ChartPoint } from "../../types";

interface Props {
  title: string;
  series: ChartPoint[];
  color: string;
  unit: string;
  dangerThreshold?: number;
}

const fmt = (iso: string) =>
  new Date(iso).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });

const VitalChart: FC<Props> = ({ title, series, color, unit, dangerThreshold }) => {
  if (!series.length) {
    return (
      <div className="card h-100">
        <div className="card-body d-flex align-items-center justify-content-center text-muted">
          No {title} data yet
        </div>
      </div>
    );
  }

  const data = series.map((p) => ({ time: fmt(p.t), value: p.v }));

  return (
    <div className="card h-100" data-testid={`chart-${title.toLowerCase().replace(/\s+/g, "-")}`}>
      <div className="card-header py-2">
        <span className="fw-semibold small">{title}</span>
        <span className="text-muted small ms-2">({unit})</span>
      </div>
      <div className="card-body px-1">
        <ResponsiveContainer width="100%" height={200}>
          <LineChart data={data} margin={{ top: 4, right: 16, left: -16, bottom: 0 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
            <XAxis dataKey="time" tick={{ fontSize: 11 }} />
            <YAxis tick={{ fontSize: 11 }} />
            <Tooltip
              formatter={(v: number) => [`${v} ${unit}`, title]}
              labelFormatter={(l) => `Time: ${l}`}
            />
            {dangerThreshold && (
              <ReferenceLine y={dangerThreshold} stroke="#dc3545" strokeDasharray="4 2" label={{ value: "⚠ threshold", fontSize: 10, fill: "#dc3545" }} />
            )}
            <Line type="monotone" dataKey="value" stroke={color} strokeWidth={2} dot={false} activeDot={{ r: 4 }} />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
};

export default VitalChart;
