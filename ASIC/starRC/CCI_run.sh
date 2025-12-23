#!/bin/bash
echo "################################start starRC !####################################"
script_dir=$(dirname "$(readpath "$0")")
calibre_dir=${script_dir}/../Calibre/lvs

if [ ! -d ${script_dir}/CCI ]; then
    mkdir ${script_dir}/CCI
fi

cd ${script_dir}/CCI
cp -f ${script_dir}/cmd_files/query_cmd ${script_dir}/CCI
calibre -query ${calibre_dir}/work/svdb < query_cmd

# cp -f ${calibre_dir}/input_files/star_cmd ${script_dir}/cmd_files/star_cmd
StartXtract -clean ${script_dir}/cmd_files/star_cmd
