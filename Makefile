.SUFFIXES:
.SUFFIXES: .scad .stl

STL_DIR = ./openscad_stl
STL_NEMA23_DIR = ./openscad_stl_nema23
SRC_DIR = ./openscad_src
OS := $(shell uname)

# macOS for some reason hides the openscad binary
ifeq ($(OS),Darwin)
  OPENSCAD_BIN = /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD
else
  OPENSCAD_BIN = openscad
endif

NEMA23_CMD = $(OPENSCAD_BIN) -D Nema17_cube_width=56 \
                             -D Nema17_screw_hole_width=66.61 \
                             -D Nema17_ring_diameter=38 \
                             -D Nema17_cube_height=56 \
                             -D Nema17_shaft_radius=3.175

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
	$(NEMA23_CMD) \
    -o $@ $(SRC_DIR)/$(basename $(notdir $@)).scad

nema23: | $(STL_NEMA23_DIR) $(STL_NEMA23_DIR)/motor_gear.stl \
	$(STL_NEMA23_DIR)/motor_bracket.stl \
	$(STL_NEMA23_DIR)/extruder_holder.stl
	$(NEMA23_CMD) \
    -D twod=true \
    -D mover=false \
    -D mounted_in_ceiling=false \
    -o layout_nema23.dxf $(SRC_DIR)/layout.scad

layout.dxf: $(SRC_DIR)/layout.scad \
	$(SRC_DIR)/util.scad \
	$(SRC_DIR)/spool_core.scad \
	$(SRC_DIR)/parameters.scad \
	$(SRC_DIR)/motor_bracket_2d.scad \
	$(SRC_DIR)/lineroller_parameters.scad \
	$(SRC_DIR)/lineroller_D.scad \
	$(SRC_DIR)/lineroller_ABC_winch.scad \
	$(SRC_DIR)/gear_parameters.scad \
	$(SRC_DIR)/layout.scad
	$(OPENSCAD_BIN) \
		-D twod=true \
		-D mover=false \
		-D mounted_in_ceiling=false \
		-o $@ $(SRC_DIR)/$(basename $(notdir $@)).scad

layout_a4.pdf: layout.dxf \
	$(SRC_DIR)/layout.scad \
	$(SRC_DIR)/util.scad \
	$(SRC_DIR)/spool_core.scad \
	$(SRC_DIR)/parameters.scad \
	$(SRC_DIR)/motor_bracket_2d.scad \
	$(SRC_DIR)/lineroller_parameters.scad \
	$(SRC_DIR)/lineroller_D.scad \
	$(SRC_DIR)/lineroller_ABC_winch.scad \
	$(SRC_DIR)/gear_parameters.scad \
	$(SRC_DIR)/layout.scad \
	$(SRC_DIR)/layout_slicer.scad
	$(OPENSCAD_BIN) \
		-D page=1 \
		-o p1.dxf $(SRC_DIR)/layout_slicer.scad; \
	$(OPENSCAD_BIN) \
		-D page=2 \
		-o p2.dxf $(SRC_DIR)/layout_slicer.scad; \
	$(OPENSCAD_BIN) \
		-D page=3 \
		-o p3.dxf $(SRC_DIR)/layout_slicer.scad; \
	$(OPENSCAD_BIN) \
		-D page=4 \
		-o p4.dxf $(SRC_DIR)/layout_slicer.scad; \
	$(OPENSCAD_BIN) \
		-D page=5 \
		-o p5.dxf $(SRC_DIR)/layout_slicer.scad; \
	$(OPENSCAD_BIN) \
		-D page=6 \
		-o p6.dxf $(SRC_DIR)/layout_slicer.scad; \
	inkscape -f p1.dxf --without-gui --export-area-drawing --export-ps p1.ps; \
	inkscape -f p2.dxf --without-gui --export-area-drawing --export-ps p2.ps; \
	inkscape -f p3.dxf --without-gui --export-area-drawing --export-ps p3.ps; \
	inkscape -f p4.dxf --without-gui --export-area-drawing --export-ps p4.ps; \
	inkscape -f p5.dxf --without-gui --export-area-drawing --export-ps p5.ps; \
	inkscape -f p6.dxf --without-gui --export-area-drawing --export-ps p6.ps; \
  sed -e "s/^0\.8 w/2\.5 w/" p1.ps > p1_sed.ps; \
  sed -e "s/^0\.8 w/2\.5 w/" p2.ps > p2_sed.ps; \
  sed -e "s/^0\.8 w/2\.5 w/" p3.ps > p3_sed.ps; \
  sed -e "s/^0\.8 w/2\.5 w/" p4.ps > p4_sed.ps; \
  sed -e "s/^0\.8 w/2\.5 w/" p5.ps > p5_sed.ps; \
  sed -e "s/^0\.8 w/2\.5 w/" p6.ps > p6_sed.ps; \
  gs -o layout_a4.pdf -sDEVICE=pdfwrite \
  -dAntiAliasColorImage=false \
  -dAntiAliasGrayImage=false \
  -dAntiAliasMonoImage=false \
  -dAutoFilterColorImages=false \
  -dAutoFilterGrayImages=false \
  -dDownsampleColorImages=false  \
  -dDownsampleGrayImages=false \
  -dDownsampleMonoImages=false \
  -dColorConversionStrategy=/LeaveColorUnchanged \
  -dConvertCMYKImagesToRGB=false \
  -dConvertImagesToIndexed=false \
  -dUCRandBGInfo=/Preserve \
  -dPreserveHalftoneInfo=true \
  -dPreserveOPIComments=true \
  -dPreserveOverprintSettings=true \
  p1_sed.ps p2_sed.ps p3_sed.ps p4_sed.ps p5_sed.ps p6_sed.ps; \
	rm p1.dxf p1.ps p1_sed.ps \
	   p2.dxf p2.ps p2_sed.ps \
	   p3.dxf p3.ps p3_sed.ps \
	   p4.dxf p4.ps p4_sed.ps \
	   p5.dxf p5.ps p5_sed.ps \
	   p6.dxf p6.ps p6_sed.ps

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
	$(SRC_DIR)/spool_core.scad \
	$(SRC_DIR)/spacer.scad \
	$(SRC_DIR)/sweep.scad \
	$(SRC_DIR)/cable_clamp.scad \
	$(SRC_DIR)/util.scad
	$(OPENSCAD_BIN) -o $@ $(SRC_DIR)/$(basename $(notdir $@)).scad

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
	$(STL_DIR)/spool_core.stl \
	$(STL_DIR)/spacer.stl \
	$(STL_DIR)/cable_clamp.stl \
	layout.dxf

$(STL_DIR):
	@echo "Creating STL_DIR $(STL_DIR)"
	mkdir -p $@

$(STL_NEMA23_DIR):
	@echo "Creating STL_NEMA23_DIR $(STL_NEMA23_DIR)"
	mkdir -p $@

.PHONY: all
