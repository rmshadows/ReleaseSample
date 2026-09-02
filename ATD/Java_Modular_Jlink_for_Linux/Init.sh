#!/bin/bash
### 用于初始化模块化文件夹
##

source Head.sh

if [ -d "src" ];then
  prompt -s "[✓] src directory exist."
else
  prompt -e "[✕] src directory not exist." 
  mkdir src
fi
if [ -d "bin" ];then
  prompt -s "[✓] bin directory exist."
else
  prompt -e "[✕] bin directory not exist."
  mkdir bin
fi
if [ -d "lib" ];then
  prompt -s "[✓] lib directory exist."
else
  prompt -e "[✕] lib directory exist." 
  mkdir lib
fi
if [ -d "m_res" ];then
  prompt -s "[✓] m_res directory exist."
else
  prompt -e "[✕] m_res directory exist." 
  mkdir m_res
fi

