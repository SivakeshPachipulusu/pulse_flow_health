import React, { useState } from "react";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import PatientList from "./components/PatientList";
import Dashboard from "./components/Dashboard";
import type { Patient } from "./types";
import "bootstrap/dist/css/bootstrap.min.css";

const App: React.FC = () => {
  const [selected, setSelected] = useState<Patient | null>(null);

  return (
    <BrowserRouter>
      <nav className="navbar navbar-dark bg-primary px-4 mb-4">
        <span className="navbar-brand fw-bold">
          <i className="bi bi-heart-pulse me-2" />
          PulseFlow Health
        </span>
        {selected && (
          <span className="text-white-50 small">{selected.full_name}</span>
        )}
      </nav>

      <div className="container-fluid px-4">
        <Routes>
          <Route
            path="/"
            element={
              selected ? (
                <Navigate to={`/patients/${selected.id}`} replace />
              ) : (
                <PatientList onSelectPatient={setSelected} />
              )
            }
          />
          <Route
            path="/patients/:id"
            element={
              selected ? (
                <Dashboard patient={selected} onBack={() => setSelected(null)} />
              ) : (
                <Navigate to="/" replace />
              )
            }
          />
        </Routes>
      </div>
    </BrowserRouter>
  );
};

export default App;
