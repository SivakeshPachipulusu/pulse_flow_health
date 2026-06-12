import React, { useState, useCallback } from "react";
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

const MetricCard: React.FC<MetricCardProps> = ({ label, value, unit, icon, critical }) => (
  <div className={`card h-100 ${critical ? "border-danger" : ""}`}>
    <div className="card-body text-center">
      <i className={`bi ${icon} fs-2 ${critical ? "text-danger" : "text-primary"}`} />
      <div className={`fs-3 fw-bold mt-1 ${critical ? "text-danger" : ""}`}>
        {value ?? "—"}
        {value != null && <small className="fs-6 fw-normal ms-1">{unit}</small>}
      </div>
      <div className="text-muted small">{label}</div>
      {critical && (
        <span className="badge bg-danger mt-1">CRITICAL</span>
      )}
    </div>
  </div>
);

const VitalsRefreshButton: React.FC<{
  patientId: string;
  onRefresh: (data: ChartData) => void;
}> = ({ patientId, onRefresh }) => {
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

const Dashboard: React.FC<Props> = ({ patient, onBack }) => {
  const [chartData, setChartData] = useState<ChartData | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);

  React.useEffect(() => {
    vitalsApi.chartData(patient.id)
      .then(({ data }) => setChartData(data))
      .catch(() => setLoadError("Could not load chart data"));
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

      {loadError && (
        <div className="alert alert-warning">{loadError}</div>
      )}

      <div className="row g-3 mb-4">
        <div className="col-6 col-md-3">
          <MetricCard
            label="Heart Rate"
            value={latest?.heart_rate ?? null}
            unit="bpm"
            icon="bi-heart-pulse-fill"
            critical={(latest?.heart_rate ?? 0) > 120}
          />
        </div>
        <div className="col-6 col-md-3">
          <MetricCard
            label="SpO₂"
            value={latest?.spo2 ?? null}
            unit="%"
            icon="bi-lungs-fill"
            critical={(latest?.spo2 ?? 100) < 90}
          />
        </div>
        <div className="col-6 col-md-3">
          <MetricCard
            label="Temperature"
            value={latest?.temperature ?? null}
            unit="°C"
            icon="bi-thermometer-half"
          />
        </div>
        <div className="col-6 col-md-3">
          <MetricCard
            label="Blood Pressure"
            value={latest?.blood_pressure ?? null}
            unit="mmHg"
            icon="bi-activity"
          />
        </div>
      </div>

      {chartData && (
        <div className="row g-3">
          <div className="col-12 col-lg-6">
            <VitalChart
              title="Heart Rate"
              series={chartData.series.heart_rate}
              color="#dc3545"
              unit="bpm"
              dangerThreshold={120}
            />
          </div>
          <div className="col-12 col-lg-6">
            <VitalChart
              title="SpO₂"
              series={chartData.series.spo2}
              color="#0d6efd"
              unit="%"
            />
          </div>
          <div className="col-12 col-lg-6">
            <VitalChart
              title="Temperature"
              series={chartData.series.temperature}
              color="#fd7e14"
              unit="°C"
            />
          </div>
          <div className="col-12 col-lg-6">
            <VitalChart
              title="Respiratory Rate"
              series={chartData.series.respiratory_rate}
              color="#20c997"
              unit="bpm"
            />
          </div>
        </div>
      )}
    </div>
  );
};

export default Dashboard;
