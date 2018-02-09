.SUFFIXES:
.SUFFIXES: .scad .stl

STL_DIR = ./openscad_stl
STL_NEMA23_DIR = ./openscad_stl_nema23
SRC_DIR = ./openscad_src

$(STL_NEMA23_DIR)/%.stl: $(SRC_DIR)/extruder_holder.scad \
	$(SRC_DIR)/parameters.scad \
	$(SRC_DIR)/sweep.scad \
	$(SRC_DIR)/gear_parameters.scad \
	$(SRC_DIR)/gear_util.scad \
	$(SRC_DIR)/gears.scad \
	$(SRC_DIR)/motor_gear.scad \
	$(SRC_DIR)/motor_bracket.scad \
	$(SRC_DIR)/extruder_holder.scad \
	$(SRC_DIR)/util.scad
	openscad -D Nema17_cube_width=56 \
         -D Nema17_screw_hole_width=66.61 \
         -D Nema17_ring_diameter=38 \
         -D Nema17_cube_height=56 \
         -D Nema17_shaft_radius=3.175 \
         -o $@ $(SRC_DIR)/$(basename $(notdir $@)).scad

nema23: | $(STL_NEMA23_DIR) $(STL_NEMA23_DIR)/motor_gear.stl \
	$(STL_NEMA23_DIR)/motor_bracket.stl \
	$(STL_NEMA23_DIR)/extruder_holder.stl

$(STL_DIR)/%.stl: $(SRC_DIR)/beam_slider_ABC.scad \
	$(SRC_DIR)/beam_slider_D.scad \
	$(SRC_DIR)/corner_clamp.scad \
	$(SRC_DIR)/extruder_holder.scad \
	$(SRC_DIR)/gear_parameters.scad \
	$(SRC_DIR)/gears.scad \
	$(SRC_DIR)/gear_util.scad \
	$(SRC_DIR)/lineroller_ABC_winch.scad \
	$(SRC_DIR)/lineroller_anchor.scad \
	$(SRC_DIR)/lineroller_D.scad \
	$(SRC_DIR)/lineroller_parameters.scad \
	$(SRC_DIR)/motor_bracket.scad \
	$(SRC_DIR)/motor_gear.scad \
	$(SRC_DIR)/parameters.scad \
	$(SRC_DIR)/spool_gear.scad \
	$(SRC_DIR)/spool.scad \
	$(SRC_DIR)/spacer.scad \
	$(SRC_DIR)/sweep.scad \
	$(SRC_DIR)/cable_clamp.scad \
	$(SRC_DIR)/util.scad
	openscad -o $@ $(SRC_DIR)/$(basename $(notdir $@)).scad

all: | $(STL_DIR) $(STL_DIR)/beam_slider_ABC.stl \
	$(STL_DIR)/beam_slider_D.stl \
	$(STL_DIR)/corner_clamp.stl \
	$(STL_DIR)/extruder_holder.stl \
	$(STL_DIR)/lineroller_ABC_winch.stl \
	$(STL_DIR)/lineroller_anchor.stl \
	$(STL_DIR)/lineroller_D.stl \
	$(STL_DIR)/motor_bracket.stl \
	$(STL_DIR)/motor_gear.stl \
	$(STL_DIR)/spool_gear.stl \
	$(STL_DIR)/spool.stl \
	$(STL_DIR)/spacer.stl \
	$(STL_DIR)/cable_clamp.stl


$(STL_DIR):
	@echo "Creating STL_DIR $(STL_DIR)"
	mkdir -p $@

$(STL_NEMA23_DIR):
	@echo "Creating STL_NEMA23_DIR $(STL_NEMA23_DIR)"
	mkdir -p $@

.PHONY: all
