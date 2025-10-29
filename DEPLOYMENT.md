# Deployment Guide

## Server Configuration

### Backend (Port 5003)
1. **Environment Variables**: Create a `.env` file in the `server` directory:
   ```
   PORT=5003
   NODE_ENV=production
   ```

2. **Install Dependencies**:
   ```bash
   cd server
   npm install
   ```

3. **Start Server**:
   ```bash
   npm start
   ```

### Frontend (Port 3003)
1. **Environment Variables**: Create a `.env` file in the `client` directory:
   ```
   REACT_APP_API_URL=http://213.136.72.33:5003
   PORT=3003
   ```

2. **Install Dependencies**:
   ```bash
   cd client
   npm install
   ```

3. **Build for Production**:
   ```bash
   npm run build
   ```

4. **Start Frontend** (if using a development server):
   ```bash
   PORT=3003 npm start
   ```

## Production Deployment

### Option 1: Full Deployment Script
```bash
npm run deploy:full
```

### Option 2: Manual Steps
1. Install all dependencies:
   ```bash
   npm run install-all
   ```

2. Build frontend:
   ```bash
   npm run build
   ```

3. Start backend:
   ```bash
   npm start
   ```

## Server URLs
- **Frontend**: http://213.136.72.33:3003
- **Backend API**: http://213.136.72.33:5003
- **Health Check**: http://213.136.72.33:5003/api/health

## CORS Configuration
The backend is configured to allow requests from:
- http://213.136.72.33:3003 (production frontend)
- http://localhost:3000 (local development)
- http://localhost:3003 (local development on port 3003)

## Notes
- The backend serves the built React app as static files
- MRMS data is fetched from NOAA's servers
- Data is cached for 5 minutes to reduce API calls
- The app will fallback to sample data if MRMS data is unavailable
