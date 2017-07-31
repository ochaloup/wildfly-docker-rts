#!/bin/bash

JBOSS_PATH=${JBOSS_PATH:-/opt/jboss/wildfly}
JBOSS_BIN_PATH="$JBOSS_PATH/bin"
JBOSS_CLI="$JBOSS_BIN_PATH/jboss-cli.sh"

function wait_for_server() {
  until `$JBOSS_CLI -c "ls /deployment" &> /dev/null`; do
    sleep 1
  done
}

function set_logging() {
  local CATEGORY="$1"
  ${JBOSS_CLI} -c --command="/subsystem=logging/logger=${CATEGORY}:read-resource()"
  if [ $? -eq 0 ]; then # OK
    ${JBOSS_CLI} -c --command="/subsystem=logging/logger=${CATEGORY}:write-attribute(name=level, value=TRACE)"
  else # FAIL
    ${JBOSS_CLI} -c --command="/subsystem=logging/logger=${CATEGORY}:add(level=TRACE)"
  fi
}

set -x
${JBOSS_BIN_PATH}/standalone.sh -c ../../docs/examples/configs/standalone-rts.xml --admin-only > /dev/null &
[ $? -ne 0 ] && echo "Fail to start server" && exit 1

wait_for_server

set_logging "com.arjuna"
set_logging "org.jboss.jbossts"
set_logging "org.narayana"

set +x

