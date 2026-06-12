import { type FC, type ReactNode } from "react";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import "@testing-library/jest-dom";
import Dashboard from "../components/Dashboard";
import { vitalsApi } from "../api/client";
import type { Patient, ChartData } from "../types";

jest.mock("../api/client");
jest.mock("recharts", () => {
  const Recharts = jest.requireActual("recharts");
  return { ...Recharts, ResponsiveContainer: ({ children }: { children: ReactNode }) => <div>{children}</div> };
});

const patient: Patient = {
  id: "uuid-1",
  mrn: "MRN001",
  first_name: "Jane",
  last_name: "Doe",
  full_name: "Jane Doe",
  gender: "female",
  date_of_birth: "1985-04-12",
  email: null,
  phone: null,
  ward: "ICU",
  status: "active",
  diagnosis_notes: null,
  created_at: new Date().toISOString(),
  updated_at: new Date().toISOString(),
};

const chartData: ChartData = {
  patient_id: "uuid-1",
  patient_mrn: "MRN001",
  generated_at: new Date().toISOString(),
  series: {
    heart_rate: [{ t: new Date().toISOString(), v: 88 }],
    spo2: [{ t: new Date().toISOString(), v: 97 }],
    temperature: [{ t: new Date().toISOString(), v: 98.6 }],
    respiratory_rate: [{ t: new Date().toISOString(), v: 16 }],
  },
  latest_reading: {
    id: "vr-1",
    patient_id: "uuid-1",
    device_id: null,
    device_type: null,
    metrics: { heart_rate: 88, spo2: 97 },
    heart_rate: 88,
    spo2: 97,
    blood_pressure: "118/76",
    temperature: 98.6,
    status: "received",
    critical: false,
    anonymized: false,
    archived: false,
    recorded_at: new Date().toISOString(),
    created_at: new Date().toISOString(),
  },
};

beforeEach(() => {
  jest.clearAllMocks();
  (vitalsApi.chartData as jest.Mock).mockResolvedValue({ data: chartData });
});

test("shows patient name and ward", async () => {
  render(<Dashboard patient={patient} onBack={jest.fn()} />);
  expect(screen.getByText("Jane Doe")).toBeInTheDocument();
  expect(screen.getByText(/ICU/)).toBeInTheDocument();
});

test("renders metric cards after data loads", async () => {
  render(<Dashboard patient={patient} onBack={jest.fn()} />);
  await waitFor(() => expect(screen.getByText("88")).toBeInTheDocument());
  expect(screen.getByText("97")).toBeInTheDocument();
});

test("refresh button triggers new data fetch", async () => {
  render(<Dashboard patient={patient} onBack={jest.fn()} />);
  await waitFor(() => screen.getByTestId("refresh-vitals-btn"));

  const newData = { ...chartData, generated_at: new Date().toISOString() };
  (vitalsApi.chartData as jest.Mock).mockResolvedValueOnce({ data: newData });

  await userEvent.click(screen.getByTestId("refresh-vitals-btn"));
  await waitFor(() => expect(vitalsApi.chartData).toHaveBeenCalledTimes(2));
});

test("refresh button is disabled while fetching after click", async () => {
  let resolve!: (v: unknown) => void;
  const pending = new Promise((r) => { resolve = r; });

  // First call loads the page, second call (on click) hangs so we can inspect disabled state
  (vitalsApi.chartData as jest.Mock)
    .mockResolvedValueOnce({ data: chartData })
    .mockReturnValueOnce(pending);

  render(<Dashboard patient={patient} onBack={jest.fn()} />);
  await waitFor(() => screen.getByTestId("refresh-vitals-btn"));

  await userEvent.click(screen.getByTestId("refresh-vitals-btn"));
  expect(screen.getByTestId("refresh-vitals-btn")).toBeDisabled();

  resolve({ data: chartData });
  await waitFor(() => expect(screen.getByTestId("refresh-vitals-btn")).not.toBeDisabled());
});

test("back button calls onBack", async () => {
  const onBack = jest.fn();
  render(<Dashboard patient={patient} onBack={onBack} />);
  await userEvent.click(screen.getByText(/Back/));
  expect(onBack).toHaveBeenCalled();
});
