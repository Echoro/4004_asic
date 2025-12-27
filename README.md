本套代码专为复旦大学集成电路设计与实验课程设计,复现4004的设计代码,并采用了部分开源代码完成测试.
这里需要的开源代码主要是完成测试中需要的ROM和RAM的模块.

主要的贡献是完成DC和innovus的全套脚本开发和ASIC\design\Makefiles文件夹下的vcs,xrun,questasim,dvt等的makefile脚本实现
里面的ASIC\PT ASIC\Calibre ASIC\formality ASIC\starRC 有待开发,ASIC\flow.sh只是一个示例,暂时不可用.

FPGA下核心开发的脚本是方便不同同学之间进行快速交换和建立工程文件使用的.由于Vivado不支持filelist.f传入文件,这里FPGA\run_bash可以阅读一下如何使用.

src文件夹是主要开发的4004源码,欢迎参考.
