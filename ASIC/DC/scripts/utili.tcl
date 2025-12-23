proc read_filelist_and_resolve {design_home filelist_name} {
    # 构建 filelist 路径
    set filelist_path [file join $design_home $filelist_name]

    # 检查文件是否存在
    if {![file exists $filelist_path]} {
        error "Filelist not found: $filelist_path"
    }

    set resolved_files {}

    # 打开并逐行读取
    set fp [open $filelist_path r]
    while {[gets $fp line] != -1} {
        # 去除首尾空白
        set line [string trim $line]

        # 跳过空行
        if {$line eq ""} {
            continue
        }

        # 跳过注释行（// 开头，允许前面有空格/制表符）
        if {[regexp {^[ \t]*//} $line]} {
            continue
        }

        # 拼接完整路径
        set full_path [file join $design_home $line]

        # （可选）警告：若文件不存在
        # if {![file exists $full_path]} {
        #     puts stderr "Warning: File not found: $full_path"
        # }

        lappend resolved_files $full_path
    }
    close $fp

    return $resolved_files
}
