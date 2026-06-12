export interface Patient {
  id: string;
  mrn: string;
  first_name: string;
  last_name: string;
  full_name: string;
  gender: string | null;
  date_of_birth: string | null;
  email: string | null;
  phone: string | null;
  ward: string | null;
  status: "active" | "discharged" | "deceased";
  diagnosis_notes: string | null;
  vital_readings?: VitalReading[];
  created_at: string;
  updated_at: string;
}

export interface VitalReading {
  id: string;
  patient_id: string;
  device_id: string | null;
  device_type: string | null;
  metrics: Record<string, unknown>;
  heart_rate: number | null;
  spo2: number | null;
  blood_pressure: string | null;
  temperature: number | null;
  status: "received" | "processing" | "flagged" | "archived";
  critical: boolean;
  anonymized: boolean;
  archived: boolean;
  recorded_at: string;
  created_at: string;
}

export interface ChartPoint {
  t: string;
  v: number;
}

export interface ChartData {
  patient_id: string;
  patient_mrn: string;
  generated_at: string;
  series: {
    heart_rate: ChartPoint[];
    spo2: ChartPoint[];
    temperature: ChartPoint[];
    respiratory_rate: ChartPoint[];
  };
  latest_reading: VitalReading | null;
}

export interface PatientsResponse {
  data: Patient[];
  total: number;
}
