import { useState, useEffect, useCallback, type FC, type FormEvent } from "react";
import type { Patient, ChartData } from "../../types";
import { vitalsApi } from "../../api/client";
import VitalChart from "../VitalChart";

interface Props {
  patient: Patient;
  onBack: () => void;
}

interface MetricCardProps {
  label: string;
  value: string | number | null;
  unit: string;
  icon: string;
  critical?: boolean;
}

const MetricCard: FC<MetricCardProps> = ({ label, value, unit, icon, critical }) => (
  <div className={`card h-100 ${critical ? "border-danger" : ""}`}>
    <div className="card-body text-center">
      <i className={`bi ${icon} fs-2 ${critical ? "text-danger" : "text-primary"}`} />
      <div className={`fs-3 fw-bold mt-1 ${critical ? "text-danger" : ""}`}>
        {value ?? "—"}
        {value != null && <small className="fs-6 fw-normal ms-1">{unit}</small>}
      </div>
      <div className="text-muted small">{label}</div>
      {critical && <span className="badge bg-danger mt-1">CRITICAL</span>}
    </div>
  </div>
);

const VitalsRefreshButton: FC<{ patientId: string; onRefresh: (data: ChartData) => void }> = ({ patientId, onRefresh }) => {
  const [loading, setLoading] = useState(false);

  const handleClick = useCallback(async () => {
    setLoading(true);
    try {
      const { data } = await vitalsApi.chartData(patientId);
      onRefresh(data);
    } catch (err) {
      console.error("Failed to refresh vitals", err);
    } finally {
      setLoading(false);
    }
  }, [patientId, onRefresh]);

  return (
    <button
      className="btn btn-primary"
      onClick={handleClick}
      disabled={loading}
      data-testid="refresh-vitals-btn"
    >
      {loading ? (
        <>
          <span className="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true" />
          Refreshing…
        </>
      ) : (
        <>
          <i className="bi bi-arrow-clockwise me-2" />
          Fetch Latest Vitals
        </>
      )}
    </button>
  );
};

const Dashboard: FC<Props> = ({ patient, onBack }) => {
  const [chartData, setChartData] = useState<ChartData | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);

  useEffect(() => {
    vitalsApi.chartData(patient.id)
      .then(({ data }) => setChartData(data))
      .catch((err) => {
        console.error("chart_data error", err);
        setLoadError(`Could not load chart data: ${err?.response?.status ?? err?.message}`);
      });
  }, [patient.id]);

  const latest = chartData?.latest_reading;

  return (
    <div>
      <div className="d-flex align-items-center mb-4 gap-3">
        <button className="btn btn-outline-secondary btn-sm" onClick={onBack}>
          <i className="bi bi-arrow-left me-1" /> Back
        </button>
        <div>
          <h4 className="mb-0">{patient.full_name}</h4>
          <small className="text-muted">MRN: {patient.mrn} · Ward: {patient.ward ?? "—"}</small>
        </div>
        <div className="ms-auto">
          <VitalsRefreshButton patientId={patient.id} onRefresh={setChartData} />
        </div>
      </div>

      {loadError && <div className="alert alert-warning">{loadError}</div>}

      <div className="row g-3 mb-4">
        <div className="col-6 col-md-3">
          <MetricCard label="Heart Rate" value={latest?.heart_rate ?? null} unit="bpm" icon="bi-heart-pulse-fill" critical={(latest?.heart_rate ?? 0) > 120} />
        </div>
        <div className="col-6 col-md-3">
          <MetricCard label="SpO₂" value={latest?.spo2 ?? null} unit="%" icon="bi-lungs-fill" critical={(latest?.spo2 ?? 100) < 90} />
        </div>
        <div className="col-6 col-md-3">
          <MetricCard label="Temperature" value={latest?.temperature ?? null} unit="°F" icon="bi-thermometer-half" />
        </div>
        <div className="col-6 col-md-3">
          <MetricCard label="Blood Pressure" value={latest?.blood_pressure ?? null} unit="mmHg" icon="bi-activity" />
        </div>
      </div>

      {chartData && (
        <div className="row g-3">
          <div className="col-12 col-lg-6">
            <VitalChart title="Heart Rate" series={chartData.series.heart_rate} color="#dc3545" unit="bpm" dangerThreshold={120} />
          </div>
          <div className="col-12 col-lg-6">
            <VitalChart title="SpO₂" series={chartData.series.spo2} color="#0d6efd" unit="%" />
          </div>
          <div className="col-12 col-lg-6">
            <VitalChart title="Temperature" series={chartData.series.temperature} color="#fd7e14" unit="°F" />
          </div>
          <div className="col-12 col-lg-6">
            <VitalChart title="Respiratory Rate" series={chartData.series.respiratory_rate} color="#20c997" unit="bpm" />
          </div>
        </div>
      )}

      <IngestTestReading patientId={patient.id} />
    </div>
  );
};

const IngestTestReading: FC<{ patientId: string }> = ({ patientId }) => {
  const [fields, setFields] = useState({ heart_rate: "82", spo2: "97", temperature: "98.6", respiratory_rate: "16", blood_pressure: "120/80" });
  const [status, setStatus] = useState<{ ok: boolean; msg: string } | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const set = (k: string, v: string) => setFields((f) => ({ ...f, [k]: v }));

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    setStatus(null);
    try {
      const { data } = await vitalsApi.create(patientId, {
        ...fields,
        heart_rate: Number(fields.heart_rate),
        spo2: Number(fields.spo2),
        temperature: Number(fields.temperature),
        respiratory_rate: Number(fields.respiratory_rate),
        device_id: "DEV-TEST-UI",
        device_type: "Manual Entry",
        recorded_at: new Date().toISOString(),
      });
      setStatus({ ok: true, msg: `Reading saved (${data.data.id.slice(0, 8)}…). Sidekiq job enqueued to anonymize.` });
    } catch (err: any) {
      setStatus({ ok: false, msg: err?.response?.data?.errors?.join(", ") ?? "Failed to post reading." });
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="card mt-4 border-secondary">
      <div className="card-header bg-light">
        <span className="fw-semibold small">
          <i className="bi bi-send me-2 text-secondary" />
          Post Test Reading — triggers Sidekiq anonymize job
        </span>
      </div>
      <div className="card-body">
        <form onSubmit={submit}>
          <div className="row g-2 align-items-end">
            {[
              { key: "heart_rate", label: "HR (bpm)" },
              { key: "spo2", label: "SpO₂ (%)" },
              { key: "temperature", label: "Temp (°F)" },
              { key: "respiratory_rate", label: "RR (bpm)" },
              { key: "blood_pressure", label: "BP (mmHg)" },
            ].map(({ key, label }) => (
              <div className="col-6 col-md-2" key={key}>
                <label className="form-label small mb-1">{label}</label>
                <input
                  className="form-control form-control-sm"
                  value={fields[key as keyof typeof fields]}
                  onChange={(e) => set(key, e.target.value)}
                />
              </div>
            ))}
            <div className="col-6 col-md-2">
              <button className="btn btn-sm btn-secondary w-100" type="submit" disabled={submitting}>
                {submitting ? <span className="spinner-border spinner-border-sm" /> : "Submit"}
              </button>
            </div>
          </div>
        </form>
        {status && (
          <div className={`alert alert-${status.ok ? "success" : "danger"} mt-3 mb-0 py-2 small`}>
            {status.msg}
          </div>
        )}
      </div>
    </div>
  );
};

export default Dashboard;
