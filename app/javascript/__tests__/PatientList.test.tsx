import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import "@testing-library/jest-dom";
import PatientList from "../components/PatientList";
import { patientsApi } from "../api/client";
import type { Patient } from "../types";

jest.mock("../api/client");

const mockPatients: Patient[] = [
  {
    id: "uuid-1",
    mrn: "MRN001",
    first_name: "Jane",
    last_name: "Doe",
    full_name: "Jane Doe",
    gender: "female",
    date_of_birth: "1985-04-12",
    email: "jane@example.com",
    phone: null,
    ward: "Cardiology",
    status: "active",
    diagnosis_notes: null,
    vital_readings: [
      {
        id: "vr-1",
        patient_id: "uuid-1",
        device_id: "dev-1",
        device_type: "Holter",
        metrics: { heart_rate: 95 },
        heart_rate: 95,
        spo2: 98,
        blood_pressure: "120/80",
        temperature: 98.6,
        status: "received",
        critical: false,
        anonymized: false,
        archived: false,
        recorded_at: new Date().toISOString(),
        created_at: new Date().toISOString(),
      },
    ],
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  },
];

const mockPaginatedResponse = {
  data: { data: mockPatients, total: 1 },
};

beforeEach(() => {
  jest.clearAllMocks();
  (patientsApi.list as jest.Mock).mockResolvedValue(mockPaginatedResponse);
});

test("renders the patients table with data", async () => {
  render(<PatientList onSelectPatient={jest.fn()} />);
  await waitFor(() => expect(screen.getByText("Jane Doe")).toBeInTheDocument());
  expect(screen.getByText("MRN001")).toBeInTheDocument();
  expect(screen.getByText("Cardiology")).toBeInTheDocument();
  expect(screen.getByText("95 bpm")).toBeInTheDocument();
});

test("shows spinner while loading", async () => {
  (patientsApi.list as jest.Mock).mockReturnValue(new Promise(() => {}));
  render(<PatientList onSelectPatient={jest.fn()} />);
  await waitFor(() => expect(screen.getByRole("status")).toBeInTheDocument(), { timeout: 500 });
});

test("shows error message on fetch failure", async () => {
  (patientsApi.list as jest.Mock).mockRejectedValue(new Error("Network error"));
  render(<PatientList onSelectPatient={jest.fn()} />);
  await waitFor(() =>
    expect(screen.getByText(/Failed to load patients/)).toBeInTheDocument()
  );
});

test("calls onSelectPatient when view button is clicked", async () => {
  const onSelect = jest.fn();
  render(<PatientList onSelectPatient={onSelect} />);
  await waitFor(() => screen.getByText("Jane Doe"));
  await userEvent.click(screen.getByRole("button", { name: "View" }));
  expect(onSelect).toHaveBeenCalledWith(mockPatients[0]);
});

test("shows 'No patients found' when list is empty", async () => {
  (patientsApi.list as jest.Mock).mockResolvedValue({
    data: { data: [], total: 0 },
  });
  render(<PatientList onSelectPatient={jest.fn()} />);
  await waitFor(() =>
    expect(screen.getByText("No patients found")).toBeInTheDocument()
  );
});

test("fires new search when query changes", async () => {
  render(<PatientList onSelectPatient={jest.fn()} />);
  await waitFor(() => screen.getByText("Jane Doe"));

  const search = screen.getByPlaceholderText(/Search name/);
  await userEvent.clear(search);
  await userEvent.type(search, "John");

  await waitFor(() =>
    expect(patientsApi.list).toHaveBeenCalledWith(
      expect.objectContaining({ q: "John" })
    )
  );});
