# Set SDK workspace
setws pl/vivado_files/acoustic_warfare.sdk

# Path to the HDF file
set hdf_file "/tools/Xilinx/SDK/2017.4/data/embeddedsw/lib/hwplatform_templates/ZC702_hw_platform/system.hdf"

# Create hardware project using the HDF file
createhw -name hw1 -hwspec $hdf_file

# Path to the new system.mss file
set new_mss_file "ps/board_support_package/system.mss"

# Create BSP based on system.mss
createbsp -name aw_udp_ps_bsp -hwproject hw1 -proc ps7_cortexa9_0 -os standalone -mss $new_mss_file

# Create application project for the ZC702 platform
createapp -name aw_udp_ps -hwproject hw1 -bsp aw_udp_ps_bsp -proc ps7_cortexa9_0 -os standalone -lang C -app {lwIP Echo Server}

# Import source files
importsource -name aw_udp_ps -path ps/

# Build all projects
projects -build