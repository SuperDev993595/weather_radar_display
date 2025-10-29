import React, { useState, useEffect } from "react";
import {
  MapContainer,
  TileLayer,
  CircleMarker,
  Popup,
  useMap,
} from "react-leaflet";
import L from "leaflet";
import axios from "axios";
import "./App.css";

// API configuration
const API_BASE_URL =
  process.env.REACT_APP_API_URL || "http://213.136.72.33:5003";

// Fix for default markers in react-leaflet
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: require("leaflet/dist/images/marker-icon-2x.png"),
  iconUrl: require("leaflet/dist/images/marker-icon.png"),
  shadowUrl: require("leaflet/dist/images/marker-shadow.png"),
});

// Component to update map bounds when data changes
function MapUpdater({ radarData }) {
  const map = useMap();

  useEffect(() => {
    if (radarData && radarData.features && radarData.features.length > 0) {
      const bounds = L.geoJSON(radarData).getBounds();
      map.fitBounds(bounds, { padding: [20, 20] });
    }
  }, [radarData, map]);

  return null;
}

// Component to render radar data as circles
function RadarOverlay({ radarData }) {
  if (!radarData || !radarData.features) {
    return null;
  }

  const getColor = (reflectivity) => {
    if (reflectivity < 0) return "#000080"; // Dark blue
    if (reflectivity < 10) return "#0000FF"; // Blue
    if (reflectivity < 20) return "#00FFFF"; // Cyan
    if (reflectivity < 30) return "#00FF00"; // Green
    if (reflectivity < 40) return "#FFFF00"; // Yellow
    if (reflectivity < 50) return "#FF8000"; // Orange
    if (reflectivity < 60) return "#FF0000"; // Red
    return "#800080"; // Purple
  };

  return (
    <>
      {radarData.features.map((feature, index) => (
        <CircleMarker
          key={index}
          center={[
            feature.geometry.coordinates[1],
            feature.geometry.coordinates[0],
          ]}
          radius={3}
          pathOptions={{
            fillColor: getColor(feature.properties.reflectivity),
            color: getColor(feature.properties.reflectivity),
            weight: 1,
            opacity: 0.8,
            fillOpacity: 0.6,
          }}
        >
          <Popup>
            <div>
              <strong>Reflectivity:</strong>{" "}
              {feature.properties.reflectivity.toFixed(1)} dBZ
              <br />
              <strong>Location:</strong>{" "}
              {feature.geometry.coordinates[1].toFixed(4)}°N,{" "}
              {feature.geometry.coordinates[0].toFixed(4)}°W
            </div>
          </Popup>
        </CircleMarker>
      ))}
    </>
  );
}

function App() {
  const [radarData, setRadarData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [lastUpdate, setLastUpdate] = useState(null);

  const fetchRadarData = async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await axios.get(`${API_BASE_URL}/api/radar-data`);
      setRadarData(response.data);
      setLastUpdate(new Date());
    } catch (err) {
      console.error("Error fetching radar data:", err);
      setError("Failed to fetch radar data. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchRadarData();

    // Refresh data every 5 minutes
    const interval = setInterval(fetchRadarData, 5 * 60 * 1000);

    return () => clearInterval(interval);
  }, []);

  const handleRefresh = () => {
    fetchRadarData();
  };

  return (
    <div className="App">
      <header className="app-header">
        <h1>Weather Radar Display</h1>
        <div className="header-controls">
          <div className="status-info">
            {loading && <span className="status loading">Loading...</span>}
            {error && <span className="status error">{error}</span>}
            {lastUpdate && !loading && !error && (
              <span className="status success">
                Last updated: {lastUpdate.toLocaleTimeString()}
              </span>
            )}
          </div>
          <button
            className="refresh-button"
            onClick={handleRefresh}
            disabled={loading}
          >
            {loading ? "Refreshing..." : "Refresh Data"}
          </button>
        </div>
      </header>

      <div className="map-container">
        <MapContainer
          center={[39.8283, -98.5795]} // Center of continental US
          zoom={4}
          style={{ height: "100%", width: "100%" }}
        >
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
          <MapUpdater radarData={radarData} />
          <RadarOverlay radarData={radarData} />
        </MapContainer>
      </div>

      <div className="legend">
        <h3>Reflectivity Scale (dBZ)</h3>
        <div className="legend-items">
          <div className="legend-item">
            <div
              className="legend-color"
              style={{ backgroundColor: "#000080" }}
            ></div>
            <span>&lt; 0</span>
          </div>
          <div className="legend-item">
            <div
              className="legend-color"
              style={{ backgroundColor: "#0000FF" }}
            ></div>
            <span>0-10</span>
          </div>
          <div className="legend-item">
            <div
              className="legend-color"
              style={{ backgroundColor: "#00FFFF" }}
            ></div>
            <span>10-20</span>
          </div>
          <div className="legend-item">
            <div
              className="legend-color"
              style={{ backgroundColor: "#00FF00" }}
            ></div>
            <span>20-30</span>
          </div>
          <div className="legend-item">
            <div
              className="legend-color"
              style={{ backgroundColor: "#FFFF00" }}
            ></div>
            <span>30-40</span>
          </div>
          <div className="legend-item">
            <div
              className="legend-color"
              style={{ backgroundColor: "#FF8000" }}
            ></div>
            <span>40-50</span>
          </div>
          <div className="legend-item">
            <div
              className="legend-color"
              style={{ backgroundColor: "#FF0000" }}
            ></div>
            <span>50-60</span>
          </div>
          <div className="legend-item">
            <div
              className="legend-color"
              style={{ backgroundColor: "#800080" }}
            ></div>
            <span>&gt; 60</span>
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
