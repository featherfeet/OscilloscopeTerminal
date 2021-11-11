#!/bin/bash

cd rtl
iverilog -o ../icarus_output test.v top.v
cd ..
