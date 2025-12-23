#!/bin/bash
VIVADO_BIN="vivado"

# 获取当前脚本的绝对路径
script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 获取脚本文件名（例如 download.sh）
script_file="$(basename "${BASH_SOURCE[0]}")"

# 获取不带扩展名的文件名（即 "download"）
script_base="${script_file%.*}"

# 拼接得到对应的 .tcl 文件路径
host_tcl_path="${script_path}/../tcl_scripts/${script_base}.tcl"

# === 执行 Vivado TCL 脚本 ===
cd $(dirname "${host_tcl_path}")/.. 
mkdir -p logs/${script_base} 
cd logs/${script_base} 
echo Current directory: \$(pwd) 
${VIVADO_BIN} -mode batch -source ${host_tcl_path}"

