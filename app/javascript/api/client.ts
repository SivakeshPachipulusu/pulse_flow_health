import axios from "axios";
import type { PatientsResponse, Patient, VitalReading, ChartData } from "../types";

const api = axios.create({
  baseURL: "/api/v1",
  headers: { "Content-Type": "application/json" },
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem("auth_token");
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

api.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err.response?.status === 401) {
      localStorage.removeItem("auth_token");
      window.location.href = "/login";
    }
    return Promise.reject(err);
  }
);

export const patientsApi = {
  list: (params?: { q?: string; ward?: string; status?: string; page?: number }) =>
    api.get<PatientsResponse>("/patients", { params }),

  get: (id: string) =>
    api.get<{ data: Patient }>(`/patients/${id}`),

  create: (data: Partial<Patient>) =>
    api.post<{ data: Patient }>("/patients", { patient: data }),

  update: (id: string, data: Partial<Patient>) =>
    api.patch<{ data: Patient }>(`/patients/${id}`, { patient: data }),
};

export const vitalsApi = {
  list: (patientId: string) =>
    api.get<{ data: VitalReading[] }>(`/patients/${patientId}/vital_readings`),

  get: (patientId: string, id: string) =>
    api.get<{ data: VitalReading }>(`/patients/${patientId}/vital_readings/${id}`),

  create: (patientId: string, payload: Record<string, unknown>) =>
    api.post<{ data: VitalReading }>(`/patients/${patientId}/vital_readings`, {
      vital_reading: payload,
    }),

  chartData: (patientId: string) =>
    api.get<ChartData>(`/patients/${patientId}/vital_readings/chart_data`),
};
