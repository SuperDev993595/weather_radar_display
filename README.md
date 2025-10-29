# Weather Radar Display

A full-stack weather radar display application that processes real-time MRMS (Multi-Radar Multi-Sensor) data and renders it on an interactive map.

## Features

- **Real-time Data**: Fetches latest Reflectivity at Lowest Altitude (RALA) data from MRMS
- **Interactive Map**: Built with React and Leaflet for smooth user experience
- **Dynamic Updates**: Automatically refreshes data every 5 minutes
- **Responsive Design**: Works on desktop and mobile devices
- **Color-coded Legend**: Easy-to-understand reflectivity scale

## Technology Stack

### Frontend
- **React 18**: Modern React with hooks
- **Leaflet**: Open-source mapping library for interactive maps
- **React-Leaflet**: React components for Leaflet integration
- **Axios**: HTTP client for API calls

### Backend
- **Node.js**: JavaScript runtime
- **Express**: Web framework
- **CORS**: Cross-origin resource sharing
- **node-fetch**: HTTP client for server-side requests

### Justification for Libraries Used

1. **Leaflet/React-Leaflet**: Implementing interactive maps from scratch would be extremely time-consuming and complex. Leaflet is a mature, well-tested library that provides all necessary mapping functionality including tile layers, markers, and user interactions.

2. **Axios**: While fetch API is available, Axios provides better error handling, request/response interceptors, and more intuitive API for HTTP requests.

3. **Express**: Essential for creating a RESTful API backend. Building a custom HTTP server would require significant additional development time.

## Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   npm run install-all
   ```

3. Start the development server:
   ```bash
   npm run dev
   ```

This will start both the backend server (port 5000) and React development server (port 3000).

## API Endpoints

- `GET /api/radar-data`: Returns the latest radar data in GeoJSON format
- `GET /api/health`: Health check endpoint

## Data Processing

The application currently uses sample data for development purposes. In production, it would:

1. Fetch GRIB2 files from MRMS NCEP servers
2. Parse the binary GRIB2 format to extract reflectivity values
3. Convert the data to GeoJSON format for frontend consumption
4. Cache data for 5 minutes to reduce server load

## Deployment

The application is configured for deployment on Render.com:

1. Connect your GitHub repository to Render
2. Create a new Web Service
3. Set the build command: `npm run build`
4. Set the start command: `npm start`
5. Deploy

## Development Notes

- The backend includes caching to prevent excessive API calls to MRMS servers
- Sample data is generated for development when MRMS data is unavailable
- The map automatically fits bounds to show all radar data
- Responsive design ensures usability on mobile devices

## Future Enhancements

- Implement actual GRIB2 parsing for real MRMS data
- Add historical data playback
- Implement different radar products (velocity, precipitation)
- Add weather alerts and warnings overlay
- Implement user preferences for data refresh intervals
