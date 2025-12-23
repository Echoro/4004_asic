proc ProcessFileList {filelist_Dir_path filelist_name proj_name} {

    set fname_list [split [FileRead $filelist_name "utf-8" "lf"] "\n"]

    foreach one_fname $fname_list {
        set one_fname [string trim $one_fname]
        if {$one_fname eq ""} {
            continue
        }

        switch -glob -- $one_fname {
            {//*} {
                continue
            }
            default {
                puts "Add file: $one_fname"
                # add_files -norecurse -fileset sources_1  -copy_to $work_dir/$proj_name/$proj_name.srcs/sources_1/new -force -quiet $one_fname
                add_files -norecurse -fileset sources_1 $one_fname
                set ext [string tolower [file extension $one_fname]]
                # set new_path [file join $work_dir $proj_name "$proj_name.srcs/sources_1/new" [file tail $one_fname]]
                set new_path $one_fname
                set file_obj [get_files -of_objects [get_filesets sources_1] $new_path]
                if {$ext eq ".vh"} {
                    if {$file_obj ne ""} {
                        set_property file_type {Verilog Header} $file_obj
                        set_property is_global_include true $file_obj
                        puts "  Set .vh file properties: $new_path"
                    } else {
                        puts "  Warning: .vh file not found in sources_1: $new_path"
                    }
                }
                if {$ext eq ".v"} {
                    if {$file_obj ne ""} {
                        set_property file_type {SystemVerilog} $file_obj
                    }
                }
                if {$ext eq ".svh"} {
                    if {$file_obj ne ""} {
                        set_property file_type SystemVerilog $file_obj
                        set_property is_global_include true $file_obj
                        puts "  Set .svh file properties: $new_path"
                    } else {
                        puts "  Warning: .svh file not found in sources_1: $new_path"
                    }
                }
                if {$ext eq ".svhh"} {
                    if {$file_obj ne ""} {
                        set_property file_type SystemVerilog $file_obj
                        set_property is_global_include true $file_obj
                        puts "  Set .svh file properties: $new_path"
                    } else {
                        puts "  Warning: .svh file not found in sources_1: $new_path"
                    }
                }
                if {$ext eq ".sv"} {
                    if {$file_obj ne ""} {
                        set_property file_type {SystemVerilog} $file_obj
                    }
                }

                if {$ext eq ".mem"} {
                    puts "  Detected .mem file, you may want to set it for simulation memory loading."
                    puts "add mem file: $new_path"
                    set_property file_type {Memory File} $file_obj
                    set_property is_global_include true $file_obj
                }

                if {$ext eq ".coe"} {
                    puts "  Detected .coe file, possibly for block memory initialization."
                    set_property is_global_include true $file_obj
                    # set_property file_type {Coefficient Files} $file_obj
                }

                if {$ext eq ".f"} {
                    set filelist_path [file normalize "$filelist_Dir_path/$one_fname"]
                    set file_dir [file dirname $filelist_path]
                    puts "  Detected .f file, processing nested file list: $filelist_path"
                    cd $file_dir
                    ProcessFileList $file_dir [file tail $one_fname] $proj_name
                    cd $filelist_Dir_path
                }

                if {$ext eq ".files"} {
                    set filelist_path [file normalize "$filelist_Dir_path/$one_fname"]
                    set file_dir [file dirname $filelist_path]
                    puts "  Detected .files file, processing nested file list: $filelist_path"
                    cd $file_dir
                    ProcessFileList $file_dir [file tail $one_fname] $proj_name
                    cd $filelist_Dir_path
                }

            }
        }
    }
}

proc FileRead {fname encode eofile} {
    if {[file readable $fname]} {
        puts "Reading file: $fname"
        set fileid [open $fname "r"]
        fconfigure $fileid -encoding $encode -translation $eofile
        set contents [read $fileid]
        close $fileid
        return $contents
    } else {
        puts "ERROR: Cannot read file $fname"
        return ""
    }
}
# Helper function to compute relative path (compatible with Tcl 8.5)
proc get_relative_path {from to} {
    # Normalize paths to remove ., .., and resolve separators
    set from [file normalize $from]
    set to [file normalize $to]

    # Split into lists
    set from_list [file split $from]
    set to_list [file split $to]

    # Find common prefix
    set i 0
    set min_len [expr {min([llength $from_list], [llength $to_list])}]
    while {$i < $min_len} {
        if {[string equal -nocase [lindex $from_list $i] [lindex $to_list $i]]} {
            incr i
        } else {
            break
        }
    }

    # If no common prefix, return absolute path (or original to)
    if {$i == 0} {
        return $to
    }

    # Number of levels to go up from 'from'
    set up_levels [expr {[llength $from_list] - $i}]
    set rel_parts {}
    for {set j 0} {$j < $up_levels} {incr j} {
        lappend rel_parts ".."
    }

    # Append the remaining parts of 'to'
    set remaining [lrange $to_list $i end]
    if {[llength $remaining] > 0} {
        set rel_parts [concat $rel_parts $remaining]
    }

    # Handle case where result is empty (same directory)
    if {[llength $rel_parts] == 0} {
        return "."
    }

    return [join $rel_parts "/"]
}

proc update_ip_outputdirs_only {ip_dir new_outputdir} {
    set ip_list [glob -nocomplain -directory $ip_dir -types f -join ** *.xci]

    if {[llength $ip_list] == 0} {
        puts "INFO: No .xci files found in $ip_dir"
        return
    }

    foreach xci_file $ip_list {
        if {![file exists $xci_file]} {
            puts "WARNING: IP file not found: $xci_file"
            continue
        }

        # Compute relative path from ip_dir to xci_file
        set rel_path [get_relative_path $ip_dir $xci_file]
        set rel_dir [file dirname $rel_path]
        if {$rel_dir eq "."} {
            set rel_dir ""
        }

        # ✅ Build per-file output directory WITHOUT modifying original new_outputdir
        set target_outputdir $new_outputdir
        if {$rel_dir ne ""} {
            set target_outputdir [file join $new_outputdir $rel_dir]
        }

        # Normalize path to avoid ../../ mess (optional but recommended)
        # Note: file normalize may not be available in very old Tcl, but Vivado Tcl supports it
        set target_outputdir [file normalize $target_outputdir]

        # Read and update file
        set fp [open $xci_file r]
        set content [read $fp]
        close $fp

        set escaped_new [string map {\\ \\\\ \" \\\"} $target_outputdir]
        set pattern {("OUTPUTDIR"\s*:\s*\[\s*\{\s*"value"\s*:\s*")[^"]*(")}

        if {[regexp $pattern $content]} {
            set new_content [regsub $pattern $content "\\1$escaped_new\\2"]
            set fp [open $xci_file w]
            puts -nonewline $fp $new_content
            close $fp
            puts "Updated OUTPUTDIR in $xci_file -> $target_outputdir"
        } else {
            puts "WARNING: OUTPUTDIR pattern not found in $xci_file"
        }
    }
}
