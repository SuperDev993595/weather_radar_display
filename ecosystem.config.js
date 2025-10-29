module.exports = {
  apps: [
    {
      name: "weather-radar-backend",
      script: "./server/index.js",
      cwd: "./",
      instances: 1,
      exec_mode: "fork",
      env: {
        NODE_ENV: "production",
        PORT: 5003,
      },
      error_file: "./logs/backend-error.log",
      out_file: "./logs/backend-out.log",
      log_file: "./logs/backend-combined.log",
      time: true,
    },
    {
      name: "weather-radar-frontend",
      script: "serve",
      args: "-s build -l 3003",
      cwd: "./client",
      instances: 1,
      exec_mode: "fork",
      env: {
        NODE_ENV: "production",
        PORT: 3003,
      },
      error_file: "../logs/frontend-error.log",
      out_file: "../logs/frontend-out.log",
      log_file: "../logs/frontend-combined.log",
      time: true,
    },
  ],
};
