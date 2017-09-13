.SUFFIXES:
.SUFFIXES: .scad .stl

STL_DIR = ./stl

$(STL_DIR)/%.stl: All_the_stls.scad parts.scad measured_numbers.scad util.scad design_numbers.scad Nema17_and_Ramps_and_bearings.scad Gears.scad
	openscad -o $@ -D 'the_part="$(basename $(notdir $@))"' All_the_stls.scad

all: | $(STL_DIR) $(STL_DIR)/Bottom_plate_qty_1.stl \
	$(STL_DIR)/Bottom_plate_qty_1.stl \
	$(STL_DIR)/Fancy_Ramps_holder_qty_1.stl \
	$(STL_DIR)/Mirrored_worm_disc_w_torx_qty_1.stl \
	$(STL_DIR)/Mirrored_worm_qty_1.stl \
	$(STL_DIR)/Motor_gear_A_qty_1.stl \
	$(STL_DIR)/Motor_gear_B_qty_1.stl \
	$(STL_DIR)/Motor_gear_C_qty_1.stl \
	$(STL_DIR)/Sandwich_gear_w_torx_qty_3.stl \
	$(STL_DIR)/Sandwich_spacer_qty_4.stl \
	$(STL_DIR)/Side_plate_left_qty_1.stl \
	$(STL_DIR)/Side_plate_right_qty_1.stl \
	$(STL_DIR)/Side_plate_straight_qty_1.stl \
	$(STL_DIR)/Snelle_w_torx_qty_4.stl \
	$(STL_DIR)/Top_plate_qty_1.stl \
	$(STL_DIR)/Sstruder_v2_adjustment_cylinder_qty_1.stl \
	$(STL_DIR)/Sstruder_v2_lever_qty_1.stl \
	$(STL_DIR)/Sstruder_v2_plate_qty_1.stl \
	$(STL_DIR)/Sstruder_v2_pressblock_handle_qty_1.stl


$(STL_DIR):
	@echo "Creating STL_DIR $(STL_DIR)"
	mkdir -p $@

.PHONY: all


