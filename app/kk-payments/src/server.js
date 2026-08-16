const express = require('express');
const healthRouter = require('./routes/health');
const paymentsRouter = require('./routes/payments');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.use(healthRouter);
app.use(paymentsRouter);

app.use((err, req, res, next) => {
  console.error(JSON.stringify({
    service: 'kk-payments',
    event: 'request_error',
    status: 'error',
    message: err.message,
    timestamp: new Date().toISOString()
  }));

  res.status(500).json({
    error: 'Internal server error'
  });
});

app.listen(PORT, () => {
  console.log(JSON.stringify({
    service: 'kk-payments',
    event: 'server_started',
    port: PORT,
    timestamp: new Date().toISOString()
  }));
});
