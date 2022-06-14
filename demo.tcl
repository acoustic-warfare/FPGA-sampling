set demo              fpga_project
set demo_constraints  ./fpga_constraint.xdc
set vivado_proj1 ../layout 
            
file mkdir ${vivado_proj1}
create_project ${demo} ${vivado_proj1}/${demo} -part xc7z020clg400-1
add_files {../fir.vhd }
import_files -force
import_files -fileset constrs_1 -force -norecurse ${demo_constraints}