# # delete all files in the log directory
# foreach file [glob -nocomplain -directory [pwd] *.log] {
#     file delete -force $file
#     puts "Deleted: $file"
# }
# foreach file [glob -nocomplain -directory [pwd] *.jou] {
#     file delete -force $file
#     puts "Deleted: $file"
# }

# set target_dir [pwd]
# # 使用 glob -nocomplain 避免无匹配时报错
# foreach dir [glob -nocomplain -type d -directory $target_dir/../ .Xil] {
#     puts "删除: $dir"
#     file delete -force $dir
# }