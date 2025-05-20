#!/bin/bash

set -euo pipefail

style=${1?Supply one of default plain simple 3line grid light round bold double; use -l/m/r to justify columns}
shift 1

csvtk -t pretty -S $style $@

