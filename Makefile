.SUFFIXES:
.SUFFIXES: .scad .stl

STL_DIR = ./openscad_stl
SRC_DIR = ./openscad_src

$(STL_DIR)/%.stl: $(SRC_DIR)/beam_clamp.scad \
	$(SRC_DIR)/beam_slider.scad \
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
	$(SRC_DIR)/tension_gauge.scad \
	$(SRC_DIR)/spool.scad \
	$(SRC_DIR)/sweep.scad \
	$(SRC_DIR)/util.scad
	openscad -o $@ $(SRC_DIR)/$(basename $(notdir $@)).scad

all: | $(STL_DIR) $(STL_DIR)/beam_clamp.stl \
	$(STL_DIR)/beam_slider.stl \
	$(STL_DIR)/corner_clamp.stl \
	$(STL_DIR)/extruder_holder.stl \
	$(STL_DIR)/lineroller_ABC_winch.stl \
	$(STL_DIR)/lineroller_anchor.stl \
	$(STL_DIR)/lineroller_D.stl \
	$(STL_DIR)/motor_bracket.stl \
	$(STL_DIR)/motor_gear.stl \
	$(STL_DIR)/spool_gear.stl \
	$(STL_DIR)/tension_gauge.stl \
	$(STL_DIR)/spool.stl


$(STL_DIR):
	@echo "Creating STL_DIR $(STL_DIR)"
	mkdir -p $@

.PHONY: all
