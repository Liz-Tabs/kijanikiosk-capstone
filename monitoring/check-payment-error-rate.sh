#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-kijani-staging}"
SERVICE="${SERVICE:-kk-payments}"
WINDOW="${WINDOW:-10m}"
THRESHOLD="${THRESHOLD:-5}"

LOG_FILE="${LOG_FILE:-/tmp/kk-payments-monitoring.log}"

echo "=== KijaniKiosk kk-payments Error Rate ==="
echo "Namespace: ${NAMESPACE}"
echo "Service: ${SERVICE}"
echo "Window: ${WINDOW}"
echo "Threshold: ${THRESHOLD}%"
echo

kubectl logs \
  -n "${NAMESPACE}" \
  -l app.kubernetes.io/name="${SERVICE}" \
  --since="${WINDOW}" \
  --prefix=true \
  > "${LOG_FILE}"

total_payments="$(
  grep -E '"event":"(payment_processed|payment_validation_failed)"' "${LOG_FILE}" \
  | wc -l
)"

error_payments="$(
  grep -E '"event":"payment_validation_failed"' "${LOG_FILE}" \
  | wc -l
)"

if [ "${total_payments}" -eq 0 ]; then
  error_rate="0.00"
else
  error_rate="$(awk -v errors="${error_payments}" -v total="${total_payments}" \
    'BEGIN { printf "%.2f", (errors / total) * 100 }')"
fi

echo "Total payment attempts: ${total_payments}"
echo "Payment errors: ${error_payments}"
echo "Error rate: ${error_rate}%"

if awk -v rate="${error_rate}" -v threshold="${THRESHOLD}" \
  'BEGIN { exit !(rate > threshold) }'
then
  echo "STATUS: ALERT - payment error rate exceeds ${THRESHOLD}%"
  exit 1
else
  echo "STATUS: OK - payment error rate is within threshold"
fi
