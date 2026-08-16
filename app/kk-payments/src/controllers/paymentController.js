const { randomUUID } = require('crypto');

function createPayment(req, res) {
  const { orderId, amount, currency = 'KES' } = req.body || {};

  if (!orderId || amount === undefined) {
    console.log(JSON.stringify({
      service: 'kk-payments',
      event: 'payment_validation_failed',
      status: 'error',
      timestamp: new Date().toISOString()
    }));

    return res.status(400).json({
      error: 'orderId and amount are required'
    });
  }

  const payment = {
    paymentId: randomUUID(),
    orderId,
    amount,
    currency,
    status: 'paid',
    timestamp: new Date().toISOString()
  };

  console.log(JSON.stringify({
    service: 'kk-payments',
    event: 'payment_processed',
    status: 'success',
    paymentId: payment.paymentId,
    orderId: payment.orderId,
    amount: payment.amount,
    timestamp: payment.timestamp
  }));

  return res.status(201).json(payment);
}

module.exports = { createPayment };
