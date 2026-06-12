import axios from "axios";
import type { PatientsResponse, VitalReading, ChartData } from "../types";

const api = axios.create({
  baseURL: "/api/v1",
  headers: {
    "Content-Type": "application/json",
    "Accept": "application/json",
  },
});

export const patientsApi = {
  list: (params?: { q?: string; ward?: string }) =>
    api.get<PatientsResponse>("/patients", { params }),
};

export const vitalsApi = {
  create: (patientId: string, payload: Record<string, unknown>) =>
    api.post<{ data: VitalReading }>(`/patients/${patientId}/vital_readings`, {
      vital_reading: payload,
    }),

  chartData: (patientId: string) =>
    api.get<ChartData>(`/patients/${patientId}/vital_readings/chart_data`),
};
