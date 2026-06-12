import { type ReactNode } from "react";
import { render, screen } from "@testing-library/react";
import "@testing-library/jest-dom";
import VitalChart from "../components/VitalChart";
import type { ChartPoint } from "../types";

jest.mock("recharts", () => {
  const Recharts = jest.requireActual("recharts");
  return {
    ...Recharts,
    ResponsiveContainer: ({ children }: { children: ReactNode }) => <div>{children}</div>,
  };
});

const series: ChartPoint[] = [
  { t: "2024-01-01T10:00:00Z", v: 72 },
  { t: "2024-01-01T10:05:00Z", v: 78 },
  { t: "2024-01-01T10:10:00Z", v: 130 },
];

test("renders chart with correct title", () => {
  render(<VitalChart title="Heart Rate" series={series} color="#dc3545" unit="bpm" />);
  expect(screen.getByText("Heart Rate")).toBeInTheDocument();
  expect(screen.getByText("(bpm)")).toBeInTheDocument();
});

test("shows empty state when no data", () => {
  render(<VitalChart title="SpO2" series={[]} color="#0d6efd" unit="%" />);
  expect(screen.getByText("No SpO2 data yet")).toBeInTheDocument();
});

test("renders chart container when data present", () => {
  render(<VitalChart title="Heart Rate" series={series} color="#dc3545" unit="bpm" dangerThreshold={120} />);
  expect(screen.getByTestId("chart-heart-rate")).toBeInTheDocument();
});
