#!/bin/bash

# format tab separated data to align, view in less.

set -euo pipefail

column -t -s $'\t' | less

