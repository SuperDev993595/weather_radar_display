const express = require("express");
const cors = require("cors");
const fetch = require("node-fetch");
const fs = require("fs");
const path = require("path");
const GRIB2Processor = require("./grib2Processor");
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 5003;

// Initialize GRIB2 processor
const grib2Processor = new GRIB2Processor();

// Middleware
app.use(
  cors({
    origin: [
      "http://213.136.72.33:3003",
      "http://localhost:3000",
      "http://localhost:3003",
    ],
    credentials: true,
  })
);
app.use(express.json());

// Serve static files from the React app build directory
app.use(express.static(path.join(__dirname, "../client/build")));

// MRMS data configuration
const MRMS_BASE_URL =
  "https://mrms.ncep.noaa.gov/2D/ReflectivityAtLowestAltitude/";
const CACHE_DURATION = 5 * 60 * 1000; // 5 minutes in milliseconds

let radarDataCache = {
  data: null,
  timestamp: null,
};

// Function to get the latest MRMS file directly
async function getLatestMRMSFile() {
  try {
    console.log("Fetching latest MRMS file directly...");

    // Use the direct latest file URL
    const latestFileName = "MRMS_ReflectivityAtLowestAltitude.latest.grib2.gz";
    const fileUrl = `${MRMS_BASE_URL}${latestFileName}`;

    console.log(`Fetching latest file: ${fileUrl}`);

    const fileResponse = await fetch(fileUrl, {
      headers: {
        "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        Accept: "application/gzip, application/octet-stream, */*",
        "Accept-Encoding": "gzip, deflate",
        Connection: "keep-alive",
      },
      timeout: 15000, // 15 second timeout for file download
    });

    if (fileResponse.ok) {
      console.log(`✅ Successfully fetched latest MRMS data from: ${fileUrl}`);
      console.log(
        `📊 File size: ${
          fileResponse.headers.get("content-length") || "unknown"
        } bytes`
      );
      return {
        url: fileUrl,
        data: await fileResponse.buffer(),
      };
    } else {
      throw new Error(
        `Failed to fetch latest file: ${fileResponse.status} ${fileResponse.statusText}`
      );
    }
  } catch (error) {
    console.error("Error fetching latest MRMS data:", error);
    // Fallback to enhanced sample data
    return {
      url: "fallback-sample",
      data: grib2Processor.generateRealisticRadarData(),
    };
  }
}

// Process MRMS data using GRIB2 processor
async function processMRMSData(rawData) {
  try {
    if (rawData && rawData.length > 0) {
      // Try to process as GRIB2 data
      return await grib2Processor.processGRIB2Data(rawData);
    } else {
      // Fallback to sample data
      return grib2Processor.generateSampleRadarData();
    }
  } catch (error) {
    console.error("Error processing MRMS data:", error);
    return grib2Processor.generateSampleRadarData();
  }
}

// API endpoint to get radar data
app.get("/api/radar-data", async (req, res) => {
  try {
    const now = Date.now();

    //Check if we have cached data that's still fresh
    if (
      radarDataCache.data &&
      radarDataCache.timestamp &&
      now - radarDataCache.timestamp < CACHE_DURATION
    ) {
      console.log("Returning cached radar data");
      return res.json(radarDataCache.data);
    }

    console.log("Fetching fresh radar data...");
    const mrmsData = await getLatestMRMSFile();
    const processedData = await processMRMSData(mrmsData.data);

    // Extract filename from URL for logging
    const fileName = mrmsData.url.split("/").pop();
    console.log(`📁 Latest file fetched: ${fileName}`);
    console.log(`🔗 Full URL: ${mrmsData.url}`);
    console.log(
      `📊 Data size: ${mrmsData.data ? mrmsData.data.length : 0} bytes`
    );

    // Add metadata about data source
    const responseData = {
      ...processedData,
      metadata: {
        dataSource: mrmsData.url.includes("mrms.ncep.noaa.gov")
          ? "MRMS"
          : "Sample",
        dataUrl: mrmsData.url,
        fileName: fileName,
        timestamp: new Date().toISOString(),
        cacheExpiry: new Date(now + CACHE_DURATION).toISOString(),
        totalPoints: processedData.features ? processedData.features.length : 0,
      },
    };

    // Update cache
    radarDataCache = {
      data: responseData,
      timestamp: now,
    };

    res.json(responseData);
  } catch (error) {
    console.error("Error processing radar data:", error);
    res.status(500).json({
      error: "Failed to fetch radar data",
      fallback: true,
      data: grib2Processor.generateRealisticRadarData(),
    });
  }
});

// Health check endpoint
app.get("/api/health", (req, res) => {
  res.json({ status: "OK", timestamp: new Date().toISOString() });
});

// Serve React app for all other routes
app.get("*", (req, res) => {
  res.sendFile(path.join(__dirname, "../client/build", "index.html"));
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(`Access the application at: http://213.136.72.33:${PORT}`);
});
