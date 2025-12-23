#!/bin/bash
# libs=(
#     saed32hvt_ff1p16vn40c
# )
# versions=(
#     saed32hvt_ff1p16vn40c
# )

libs=(

    saed32hvt_ff1p16vn40c \
    saed32hvt_ss0p75v25c  \
    # saed32lvt_ff1p16vn40c \
    # saed32lvt_ss0p75v25c  \

)
versions=(
    saed32hvt_ff1p16vn40c \
    saed32hvt_ss0p75v25c  \
    # saed32lvt_ff1p16vn40c \
    # saed32lvt_ss0p75v25c  \
)

LIB_DIRS=(
    "/home/eda/PDK/32-28nm_EDK_12162019/SAED32_EDK/lib/stdcell_hvt/db_nldm" \
    "/home/eda/PDK/32-28nm_EDK_12162019/SAED32_EDK/lib/stdcell_hvt/db_nldm" \
# "/home/eda/PDK/32-28nm_EDK_12162019/SAED32_EDK/lib/stdcell_lvt/db_nldm" \
# "/home/eda/PDK/32-28nm_EDK_12162019/SAED32_EDK/lib/stdcell_lvt/db_nldm" \
)


libs=(
    smic13_tt \
    smic13_ss \
    smic13_ff
)
versions=(
    smic13_tt \
    smic13_ss \
    smic13_ff
)
# 包含lib和db的文件夹路径
LIB_DIRS=(
    "/home/eda/PDK/smic130/Synopsys" \
    "/home/eda/PDK/smic130/Synopsys" \
    "/home/eda/PDK/smic130/Synopsys" \
)

log_dir="run_log"
len=${#libs[@]}
[ ${#versions[@]} -lt ${len} ] && len=${#versions[@]}

for (( i=0; i<$len; i++)); do
    lib="${libs[$i]}"
    version="${versions[$i]}"
    LIB_DIR="${LIB_DIRS[$i]}"

    if [ ! -d "$log_dir" ]; then  # "!" 表示取反：若目录不存在
    mkdir -p "$log_dir"          # 创建目录
    echo "目录 $log_dir 创建成功"  # 可选：创建后的操作（如日志）
    fi

    dc_shell -f scripts/batch_compile.tcl -x "set LIB_DIR $LIB_DIR ;set LIBRARY_NAME $lib; set VERSION $version" | tee ${log_dir}/${version}.log
done

wait
echo "All runs done.."
# find ./ -type d -name "400m" -exec rm -r {} +

rm *.pvl
rm *.syn
rm *.mr
rm *.svf
rm *.log
rm change_names
