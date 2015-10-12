#!/usr/bin/env bash

# Run a spark job on a EMR yarn cluster.
# Note: It requires the generate-spark-submit-yarn.sh to run during the
# EMR bootstrap stage, which will generate a script to run spark-submit with
# prepopulated yarn parameters.

# Die if anything happens
set -ex

# Usage
if [[ "$#" -lt 2 ]]; then
  echo "Usage: $0 <jar-s3-uri> <class> [<args>]" >&2
  exit 1
fi

EMR_HOME="/home/hadoop"
ENV_FILE="${EMR_HOME}/hyperion_env.sh"

[ -f ${ENV_FILE} ] && source ${ENV_FILE}

EMR_SPARK_HOME="${EMR_HOME}/spark"
HYPERION_HOME="${EMR_HOME}/hyperion"

mkdir -p ${HYPERION_HOME}

REMOTE_JAR_LOCATION=$1; shift
JOB_CLASS=$1; shift

LOCAL_JAR_DIR="$(mktemp -p $HYPERION_HOME -d -t jars_XXXXXX)"
JAR_NAME="${REMOTE_JAR_LOCATION##*/}"
LOCAL_JAR="${LOCAL_JAR_DIR}/${JAR_NAME}"

# Download JAR file from S3 to local
hadoop fs -get ${REMOTE_JAR_LOCATION} ${LOCAL_JAR}

exec ${EMR_SPARK_HOME}/bin/spark-submit --master yarn-client --driver-memory 9g --class ${JOB_CLASS} ${LOCAL_JAR} $@
