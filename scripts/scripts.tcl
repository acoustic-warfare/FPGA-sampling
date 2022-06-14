set SCRATCH                         fpga/project
ser SCRATCH_CONSTRAINT              ./fpga.costraint.xdc

set DIR_OUTPUT ../vivado_proj

file mkdir ${DIR_OUTPUT}

create_project ${SCRATCH} $ {DIR_OUTPUT}/${SCRATCH} -part xc7z020clg400-1

add_files {../vhdl/fir.vhd }

import_files -force

import_files -fileset constrs_1 -force -norecurse $ {SCRATCH_CONSTRAINT}

