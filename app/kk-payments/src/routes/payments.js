const express = require('express');
const { createPayment } = require('../controllers/paymentController');

const router = express.Router();

router.post('/payments', createPayment);

module.exports = router;
