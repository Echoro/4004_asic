#!/bin/bash

VIVADO_BIN="vivado"

# 显示帮助信息
show_help() {
    cat <<EOF
Usage: $0 [OPTION]

Run Vivado in batch mode with a corresponding TCL script.

Options:
  --help        Display this help message and exit.
  --init        Run 'init.tcl' instead of the default script.
  --download    Run 'download.tcl'
  --synth       Run 'synth.tcl'
  --implement   Run 'implement.tcl'
  --flow        Run 'flow.tcl'
  --part PART   Specify FPGA part (e.g., xc7a35tfgg484-2). Used with --name.
  --name NAME   Specify project name (e.g., usb_zerocore). Used with --part.
                When both --part and --name are given, generate 'setenv.tcl'.
    --board BOARD Specify board part (e.g., xilinx.com:zcu102:part0:3.4). Used with --name and --part.
    --top TOP     Specify top module name. Used with --name and --part.

Default behavior:
  If no option is given, runs '../tcl_scripts/<script_name>.tcl'
  where <script_name> is this script's name without extension.

Example:
  $0                # runs ../tcl_scripts/download.tcl
  $0 --init         # runs ../tcl_scripts/init.tcl
  $0 --part xc7a35tfgg484-2 
                    # sets the part to xc7a35tfgg484-2 in setenv.tcl
  $0 --name usb_zerocore 
                    # generates setenv.tcl with specified part and name
  $0 --board xilinx.com:zcu102:part0:3.4   
                    # sets the board part to xilinx.com:zcu102:part0:3.4 in setenv.tcl
  $0 --top TOP_CORE
                    # sets the top module to TOP_CORE in setenv.tcl
EOF
}

# 获取当前脚本的绝对路径
script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
script_file="$(basename "${BASH_SOURCE[0]}")"
script_base="${script_file%.*}"
setenv_path="${script_path}/../tcl_scripts/setenv.tcl"

# 默认行为：使用脚本名对应的 TCL 文件
tcl_script_name=""
log_name=""
# 初始化变量
part=""
board=""
name=""
generate_setenv=false
top=""
# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h)
            show_help
            exit 0
            ;;
        --init)
            if [[ -n "$tcl_script_name" ]]; then
                echo "Error: execute more than one file" >&2
                exit 1
            fi
            tcl_script_name="init.tcl"
            log_name="init"
            shift
            ;;
        --download)
            if [[ -n "$tcl_script_name" ]]; then
                echo "Error: execute more than one file" >&2
                exit 1
            fi
            tcl_script_name="download.tcl"
            log_name="download"
            shift
            ;;
        --synth)
            if [[ -n "$tcl_script_name" ]]; then
                echo "Error: execute more than one file" >&2
                exit 1
            fi
            tcl_script_name="synth.tcl"
            log_name="synth"
            shift
            ;;
        --implement)
            if [[ -n "$tcl_script_name" ]]; then
                echo "Error: execute more than one file" >&2
                exit 1
            fi
            tcl_script_name="implement.tcl"
            log_name="implement"
            shift
            ;;
        --flow)
            if [[ -n "$tcl_script_name" ]]; then
                echo "Error: execute more than one file" >&2
                exit 1
            fi
            tcl_script_name="flow.tcl"
            log_name="flow"
            shift
            ;;
        --part)
            if [[ -z "$2" ]]; then
                echo "Error: --part requires an argument." >&2
                exit 1
            fi
            part="$2"
            generate_setenv=true
            shift 2
            ;;
        --board)
            if [[ -z "$2" ]]; then
                echo "Error: --board requires an argument." >&2
                exit 1
            fi
            board="$2"
            generate_setenv=true
            shift 2
            ;;
        --name)
            if [[ -z "$2" ]]; then
                echo "Error: --name requires an argument." >&2
                exit 1
            fi
            name="$2"
            generate_setenv=true
            shift 2
            ;;
        --top)
            if [[ -z "$2" ]]; then
                echo "Error: --top requires an argument." >&2
                exit 1
            fi
            top="$2"
            generate_setenv=true
            shift 2
            ;;
        *)
            echo "Error: Unknown option '$1'" >&2
            show_help
            exit 1
            ;;
    esac
done

# 如果指定了 --part 和 --name，则生成 setenv.tcl 并退出（不运行 Vivado）
if [[ "$generate_setenv" == true ]]; then
    if [[ -z "$part" || -z "$name" ]]; then
        echo "Error: Both --part and --name must be specified together." >&2
        exit 1
    fi

    cat > "$setenv_path" <<EOF

# Set the system encoding to UTF-8
encoding system utf-8
# Set the maximum number of threads
set_param general.maxThreads 32
# Set the flow variable
set TOP $top
set syn_ip 1
set BOARD "$board"
set proj_name "$name"
set PART "$part"
set work_dir [pwd]/../../
set checkpoint_dir "./checkpoints"
set output_dcp \$work_dir/\$checkpoint_dir/synth.dcp
source \$work_dir/tcl_scripts/predo.tcl
source \$work_dir/tcl_scripts/utils.tcl
EOF

    echo "Generated: $setenv_path"
fi

# 构建 TCL 脚本的绝对路径
host_tcl_path="${script_path}/../tcl_scripts/${tcl_script_name}"

# 检查 TCL 脚本是否存在
if [[ ! -f "${host_tcl_path}" ]]; then
    echo "Error: TCL script not found: ${host_tcl_path}" >&2
    exit 1
fi
if [[ ! -f "${setenv_path}" ]]; then
    echo "Error: TCL script not found: ${setenv_path}" >&2
    exit 1
fi

# 创建日志目录并进入
work_dir="${script_path}/../"
find $work_dir -name ".Xil" -type d -exec rm -rf {} +

log_dir="${script_path}/../logs/${log_name}"
mkdir -p "${log_dir}"
cd "${log_dir}" || { echo "Error: Failed to cd into ${log_dir}" >&2; exit 1; }

find $log_dir -name "*.log" -type f -exec rm -f {} +
find $log_dir -name "*.jou" -type f -exec rm -f {} +

echo "Current directory: $(pwd)"
echo "Running Vivado with script: ${host_tcl_path}"

# 执行 Vivado
"${VIVADO_BIN}" -mode batch -source "${host_tcl_path}"