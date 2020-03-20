#!/bin/sh
# ------------------------------------------------------------------------
# Copyright 2019 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License
# ------------------------------------------------------------------------

set -e

# volume mounts
config_volume=${WORKING_DIRECTORY}/wso2-config-volume
artifact_volume=${WORKING_DIRECTORY}/wso2-artifact-volume

# check if the WSO2 non-root user home exists
test ! -d ${WORKING_DIRECTORY} && echo "WSO2 Docker non-root user home does not exist" && exit 1

# check if the WSO2 product home exists
test ! -d ${WSO2_SERVER_HOME} && echo "WSO2 Docker product home does not exist" && exit 1

# copy any configuration changes mounted to config_volume
test -d ${config_volume} && [[ "$(ls -A ${config_volume})" ]] && cp -RL ${config_volume}/* ${WSO2_SERVER_HOME}/
# copy any artifact changes mounted to artifact_volume
test -d ${artifact_volume} && [[ "$(ls -A ${artifact_volume})" ]] && cp -RL ${artifact_volume}/* ${WSO2_SERVER_HOME}/

IP=$(ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1)
#IP=$(curl http://checkip.amazonaws.com)
#echo "$(curl http://localhost:51678/v1/tasks)"
echo "$ECS_CONTAINER_METADATA_URI"
echo "$(curl $ECS_CONTAINER_METADATA_URI/task)"
DEPLOYMENT_YAML=${WSO2_SERVER_HOME}/conf/server/deployment.yaml
echo "$IP"
sed -i "s/localhost/$IP/" "$DEPLOYMENT_YAML"

# start WSO2 server
sh ${WSO2_SERVER_HOME}/bin/server.sh "$@"
