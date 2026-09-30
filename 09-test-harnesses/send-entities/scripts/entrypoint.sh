#!/bin/sh

## Parameters - ensure they are properly set in the environment
# Expected env vars (see EXAMPLE.env):
#   MFT_HARNESS_01_SFTP_SERVER_FQDN
#   MFT_HARNESS_01_SFTP_SERVER_PORT
#   MFT_HARNESS_01_SFTP_CLIENT_USER_NAME
#   MFT_HARNESS_01_SFTP_CLIENT_USER_PASSWORD
#   MFT_HARNESS_01_SFTP_BASE_UPLOAD_DIR
#   MFT_HARNESS_01_DEBUG

## Env vars Validation

  __validation_errors=0

  if [ -z "${MFT_HARNESS_01_SFTP_SERVER_FQDN}" ]; then
    echo "ERROR: MFT_HARNESS_01_SFTP_SERVER_FQDN is not set" >&2
    __validation_errors=$((__validation_errors + 1))
  fi

  if [ -z "${MFT_HARNESS_01_SFTP_SERVER_PORT}" ]; then
    echo "ERROR: MFT_HARNESS_01_SFTP_SERVER_PORT is not set" >&2
    __validation_errors=$((__validation_errors + 1))
  fi

  if [ -z "${MFT_HARNESS_01_SFTP_CLIENT_USER_NAME}" ]; then
    echo "ERROR: MFT_HARNESS_01_SFTP_CLIENT_USER_NAME is not set" >&2
    __validation_errors=$((__validation_errors + 1))
  fi

  if [ -z "${MFT_HARNESS_01_SFTP_CLIENT_USER_PASSWORD}" ]; then
    echo "ERROR: MFT_HARNESS_01_SFTP_CLIENT_USER_PASSWORD is not set" >&2
    __validation_errors=$((__validation_errors + 1))
  fi

  if [ -z "${MFT_HARNESS_01_SFTP_BASE_UPLOAD_DIR}" ]; then
    echo "ERROR: MFT_HARNESS_01_SFTP_BASE_UPLOAD_DIR is not set" >&2
    __validation_errors=$((__validation_errors + 1))
  fi

  if [ "${__validation_errors}" -gt 0 ]; then
    echo "ERROR: ${__validation_errors} required environment variable(s) are missing. Aborting." >&2
    exit 1
  fi

  unset __validation_errors

## Ensure the server host key is in the SSH cache volume
  __known_hosts=/ssh-cache/known_hosts
  touch "${__known_hosts}"

## Prepare zip file with checksums
  __timestamp=$(date +%y-%m-%d_%s)

  mkdir -p "/tmp/harness/${__timestamp}/payloads"

  cd "/tmp/harness/${__timestamp}" || exit 2

  cp -R /fixtures/files-to-send/* payloads/

  # the shellcheck inter detection is wrong here, quoting this $() alters the result
  # shellcheck disable=SC2046
  sha256sum $(find ./payloads -type f) > SHA256SUMS

  zip -r "../payloads_${__timestamp}.zip" ./*

## Upload the zip file to the server
echo "Uploading fixtures zip into folder ${MFT_HARNESS_01_SFTP_BASE_UPLOAD_DIR} ...."

## Upload to SFTP server
sshpass -p "${MFT_HARNESS_01_SFTP_CLIENT_USER_PASSWORD}" \
  sftp -o StrictHostKeyChecking=accept-new \
      -o UserKnownHostsFile="${__known_hosts}" \
      -o HostkeyAlgorithms=+ssh-rsa \
      -o PubkeyAcceptedAlgorithms=+ssh-rsa \
      -P "${MFT_HARNESS_01_SFTP_SERVER_PORT}" \
    "${MFT_HARNESS_01_SFTP_CLIENT_USER_NAME}@${MFT_HARNESS_01_SFTP_SERVER_FQDN}" <<EOF
pwd
cd ${MFT_HARNESS_01_SFTP_BASE_UPLOAD_DIR}
put ../payloads_${__timestamp}.zip
bye
EOF

__result_code=$?

echo "Uploaded, result is ${__result_code}"

## If needed, save the fixtures zip file for debug

  if [ "${MFT_HARNESS_01_DEBUG}" = "true" ]; then
    cp "../payloads_${__timestamp}.zip" /scripts/
  fi

## Final cleanup
  unset __known_hosts
  unset __timestamp
  if [ "${__result_code}" -ne 0 ]; then
    unset __result_code
    exit 3
  fi
  unset __result_code

