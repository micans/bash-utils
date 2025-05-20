#!/bin/bash

set -euo pipefail

style=${1?$'\n'----$'\n'Supply one of default plain simple 3line grid light round bold double$'\n'Use -l/m/r to justify columns$'\n'csvtk pretty -h for more options$'\n'----}
shift 1

csvtk -t pretty -S $style $@

