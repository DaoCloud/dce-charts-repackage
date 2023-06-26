#!/bin/bash

set -x
set -o errexit
set -o nounset
set -o pipefail


CURRENT_DIR_PATH=$(cd $(dirname $0); pwd)

cd $CURRENT_DIR_PATH

cp parent/README.md nvidia-vgpu/README.md