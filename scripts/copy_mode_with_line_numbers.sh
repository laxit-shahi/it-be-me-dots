#!/usr/bin/env bash

script_path=$(realpath "${BASH_SOURCE[0]}")
script_dir=$(cd -- "$(dirname -- "$script_path")" && pwd)
exec "$script_dir/line_numbers.sh"
