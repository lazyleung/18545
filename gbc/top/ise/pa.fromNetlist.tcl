
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name top -dir "C:/Users/ash/Documents/18545/gbc/top/ise/planAhead_run_1" -part xc5vlx110tff1136-1
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Users/ash/Documents/18545/gbc/top/ise/cpu_mem_integration.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/ash/Documents/18545/gbc/top/ise} }
set_property target_constrs_file "C:/Users/ash/Documents/18545/gbc/top/lcd_top.ucf" [current_fileset -constrset]
add_files [list {C:/Users/ash/Documents/18545/gbc/top/lcd_top.ucf}] -fileset [get_property constrset [current_run]]
link_design
