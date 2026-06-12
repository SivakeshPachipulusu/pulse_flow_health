import { useState, useCallback, useEffect, type FC } from "react";
import type { Patient } from "../../types";
import { patientsApi } from "../../api/client";

interface Props {
  onSelectPatient: (patient: Patient) => void;
}

const StatusBadge: FC<{ status: Patient["status"] }> = ({ status }) => {
  const colorMap = { active: "success", discharged: "secondary", deceased: "dark" } as const;
  return (
    <span className={`badge bg-${colorMap[status]}`}>
      {status.charAt(0).toUpperCase() + status.slice(1)}
    </span>
  );
};

const PatientList: FC<Props> = ({ onSelectPatient }) => {
  const [patients, setPatients] = useState<Patient[]>([]);
  const [query, setQuery] = useState("");
  const [ward, setWard] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchPatients = useCallback(async (q: string, w: string) => {
    setLoading(true);
    setError(null);
    try {
      const { data } = await patientsApi.list({ q: q || undefined, ward: w || undefined });
      setPatients(data.data);
    } catch {
      setError("Failed to load patients. Please try again.");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchPatients(query, ward);
  }, [fetchPatients, query, ward]);

  return (
    <div className="card shadow-sm">
      <div className="card-header d-flex align-items-center justify-content-between">
        <h5 className="mb-0">
          <i className="bi bi-people-fill me-2 text-primary" />
          Patients
        </h5>
        <div className="d-flex gap-2">
          <input
            type="search"
            className="form-control form-control-sm"
            placeholder="Search name / MRN / notes…"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            aria-label="Search patients"
          />
          <input
            type="text"
            className="form-control form-control-sm"
            placeholder="Ward"
            value={ward}
            onChange={(e) => setWard(e.target.value)}
            aria-label="Filter by ward"
          />
        </div>
      </div>

      <div className="card-body p-0">
        {error && <div className="alert alert-danger m-3" role="alert">{error}</div>}

        {loading ? (
          <div className="text-center py-5">
            <div className="spinner-border text-primary" role="status">
              <span className="visually-hidden">Loading…</span>
            </div>
          </div>
        ) : (
          <div className="table-responsive">
            <table className="table table-hover mb-0" data-testid="patients-table">
              <thead className="table-light">
                <tr>
                  <th>Name</th>
                  <th>MRN</th>
                  <th>Ward</th>
                  <th>Status</th>
                  <th>Latest HR</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {patients.length === 0 ? (
                  <tr>
                    <td colSpan={6} className="text-center text-muted py-4">No patients found</td>
                  </tr>
                ) : (
                  patients.map((p) => {
                    const latest = p.vital_readings?.[0];
                    return (
                      <tr key={p.id}>
                        <td className="fw-semibold">{p.full_name}</td>
                        <td><code>{p.mrn}</code></td>
                        <td>{p.ward ?? "—"}</td>
                        <td><StatusBadge status={p.status} /></td>
                        <td>
                          {latest?.heart_rate != null ? (
                            <span className={latest.critical ? "text-danger fw-bold" : ""}>
                              {latest.heart_rate} bpm
                              {latest.critical && <i className="bi bi-exclamation-triangle-fill ms-1" />}
                            </span>
                          ) : "—"}
                        </td>
                        <td>
                          <button className="btn btn-sm btn-outline-primary" onClick={() => onSelectPatient(p)}>
                            View
                          </button>
                        </td>
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
};

export default PatientList;
