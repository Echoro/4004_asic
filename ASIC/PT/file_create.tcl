### file : file_create.tcl

if {[file exist $RPT_DIR/VERSION]} {
    echo "File $RPT_DIR/VERSION already exist"
    # exec rm $RPT_DIR/VERSION -r
    # exec mkdir -p $RPT_DIR/VERSION
    # echo "Re-create VERSION files"
} else {
    exec mkdir -p $RPT_DIR/VERSION
    echo "Creating VERSION in $RPT_DIR !!!"
}

if {[file exist $OUT_DIR/VERSION]} {
    echo "File $OUT_DIR/VERSION already exist"
    # exec rm $OUT_DIR/VERSION -r
    # exec mkdir -p $OUT_DIR/VERSION
    # echo "Re-create VERSION files"
} else {
    exec mkdir -p $OUT_DIR/VERSION
    echo "Creating VERSION in $OUT_DIR !!!"
}
