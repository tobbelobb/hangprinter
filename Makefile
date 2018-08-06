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

# We let Make abuse some constants,
# like Nema17_cube_width and a4_width
# to get some flexibility
NEMA23_CMD = $(OPENSCAD_BIN) -D Nema17_cube_width=56 \
                             -D Nema17_screw_hole_width=66.61 \
                             -D Nema17_ring_diameter=38 \
                             -D Nema17_cube_height=56 \
                             -D Nema17_shaft_radius=3.175

# Tell Openscad to output some custom sized svgs
# Edit some of their parameters with sed
# Then tell inkscape to make pdf files out of them
# Then use Ghostscript to glue together the pdf
# Then clean up
make_layout_pdf_ = \
               $(OPENSCAD_BIN) -D page=1 -D 'layout_file=$(1)' -D a4_width=$(3) -D a4_length=$(4) -o p1.svg $(SRC_DIR)/layout_slicer.scad; \
               $(OPENSCAD_BIN) -D page=2 -D 'layout_file=$(1)' -D a4_width=$(3) -D a4_length=$(4) -o p2.svg $(SRC_DIR)/layout_slicer.scad; \
               $(OPENSCAD_BIN) -D page=3 -D 'layout_file=$(1)' -D a4_width=$(3) -D a4_length=$(4) -o p3.svg $(SRC_DIR)/layout_slicer.scad; \
               $(OPENSCAD_BIN) -D page=4 -D 'layout_file=$(1)' -D a4_width=$(3) -D a4_length=$(4) -o p4.svg $(SRC_DIR)/layout_slicer.scad; \
               $(OPENSCAD_BIN) -D page=5 -D 'layout_file=$(1)' -D a4_width=$(3) -D a4_length=$(4) -o p5.svg $(SRC_DIR)/layout_slicer.scad; \
               $(OPENSCAD_BIN) -D page=6 -D 'layout_file=$(1)' -D a4_width=$(3) -D a4_length=$(4) -o p6.svg $(SRC_DIR)/layout_slicer.scad; \
               sed -e "s/<svg width=\"$(3)\" height=\"$(4)\"/<svg width=\"$(3)mm\" height=\"$(4)mm\"/" p1.svg > p1_sed.svg; \
               sed -e "s/<svg width=\"$(3)\" height=\"$(4)\"/<svg width=\"$(3)mm\" height=\"$(4)mm\"/" p2.svg > p2_sed.svg; \
               sed -e "s/<svg width=\"$(3)\" height=\"$(4)\"/<svg width=\"$(3)mm\" height=\"$(4)mm\"/" p3.svg > p3_sed.svg; \
               sed -e "s/<svg width=\"$(3)\" height=\"$(4)\"/<svg width=\"$(3)mm\" height=\"$(4)mm\"/" p4.svg > p4_sed.svg; \
               sed -e "s/<svg width=\"$(3)\" height=\"$(4)\"/<svg width=\"$(3)mm\" height=\"$(4)mm\"/" p5.svg > p5_sed.svg; \
               sed -e "s/<svg width=\"$(3)\" height=\"$(4)\"/<svg width=\"$(3)mm\" height=\"$(4)mm\"/" p6.svg > p6_sed.svg; \
               sed -e "s/fill=\"lightgray\"/fill=\"white\"/" p1_sed.svg > p1_sed2.svg; \
               sed -e "s/fill=\"lightgray\"/fill=\"white\"/" p2_sed.svg > p2_sed2.svg; \
               sed -e "s/fill=\"lightgray\"/fill=\"white\"/" p3_sed.svg > p3_sed2.svg; \
               sed -e "s/fill=\"lightgray\"/fill=\"white\"/" p4_sed.svg > p4_sed2.svg; \
               sed -e "s/fill=\"lightgray\"/fill=\"white\"/" p5_sed.svg > p5_sed2.svg; \
               sed -e "s/fill=\"lightgray\"/fill=\"white\"/" p6_sed.svg > p6_sed2.svg; \
               sed -e "s/stroke-width=\"0\.5\"/stroke-width=\"0\.8\"/" p1_sed2.svg > p1_sed3.svg; \
               sed -e "s/stroke-width=\"0\.5\"/stroke-width=\"0\.8\"/" p2_sed2.svg > p2_sed3.svg; \
               sed -e "s/stroke-width=\"0\.5\"/stroke-width=\"0\.8\"/" p3_sed2.svg > p3_sed3.svg; \
               sed -e "s/stroke-width=\"0\.5\"/stroke-width=\"0\.8\"/" p4_sed2.svg > p4_sed3.svg; \
               sed -e "s/stroke-width=\"0\.5\"/stroke-width=\"0\.8\"/" p5_sed2.svg > p5_sed3.svg; \
               sed -e "s/stroke-width=\"0\.5\"/stroke-width=\"0\.8\"/" p6_sed2.svg > p6_sed3.svg; \
               cairosvg p1_sed3.svg -o p1.pdf; \
               cairosvg p2_sed3.svg -o p2.pdf; \
               cairosvg p3_sed3.svg -o p3.pdf; \
               cairosvg p4_sed3.svg -o p4.pdf; \
               cairosvg p5_sed3.svg -o p5.pdf; \
               cairosvg p6_sed3.svg -o p6.pdf; \
               gs -o $(2) -sDEVICE=pdfwrite \
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
               p1.pdf p2.pdf p3.pdf p4.pdf p5.pdf p6.pdf; \
               rm p1.svg p1_sed.svg p1_sed2.svg p1_sed3.svg p1.pdf \
                  p2.svg p2_sed.svg p2_sed2.svg p2_sed3.svg p2.pdf \
                  p3.svg p3_sed.svg p3_sed2.svg p3_sed3.svg p3.pdf \
                  p4.svg p4_sed.svg p4_sed2.svg p4_sed3.svg p4.pdf \
                  p5.svg p5_sed.svg p5_sed2.svg p5_sed3.svg p5.pdf \
                  p6.svg p6_sed.svg p6_sed2.svg p6_sed3.svg p6.pdf

# Magic numbers are size of A4 paper in mm
make_layout_pdf_a4 = $(call make_layout_pdf_,$(1),$(2),210,297)

# Magic numbers are size of letter paper in mm. Must be integers for openscad svg export to work.
make_layout_pdf_letter = $(call make_layout_pdf_,$(1),$(2),216,279)

$(STL_NEMA23_DIR)/%.stl: $(SRC_DIR)/extruder_holder.scad \
	$(SRC_DIR)/parameters.scad \
	$(SRC_DIR)/gear_util.scad \
	$(SRC_DIR)/gears.scad \
	$(SRC_DIR)/motor_gear.scad \
	$(SRC_DIR)/motor_bracket.scad \
	$(SRC_DIR)/extruder_holder.scad \
	$(SRC_DIR)/util.scad
	$(NEMA23_CMD) \
    -o $@ $(SRC_DIR)/$(basename $(notdir $@)).scad

layout_nema23.dxf: $(SRC_DIR)/layout.scad \
	$(SRC_DIR)/util.scad \
	$(SRC_DIR)/spool_core.scad \
	$(SRC_DIR)/parameters.scad \
	$(SRC_DIR)/motor_bracket_2d.scad \
	$(SRC_DIR)/lineroller_D.scad \
	$(SRC_DIR)/lineroller_ABC_winch.scad \
	$(SRC_DIR)/layout.scad
	$(NEMA23_CMD) \
    -D twod=true \
    -D mover=false \
    -D mounted_in_ceiling=false \
		-D bottom_triangle=false \
    -o $@ $(SRC_DIR)/layout.scad;

nema23: | $(STL_NEMA23_DIR) $(STL_NEMA23_DIR)/motor_gear.stl \
	$(STL_NEMA23_DIR)/motor_bracket.stl \
	$(STL_NEMA23_DIR)/extruder_holder.stl \
	layout_nema23.dxf

layout_nema23_a4.pdf: layout_nema23.dxf
	$(call make_layout_pdf_a4,"../layout_nema23.dxf",$@)

layout_nema23_letter.pdf: layout_nema23.dxf
	$(call make_layout_pdf_letter,"../layout_nema23.dxf",$@)

layout_letter.pdf: layout.dxf
	$(call make_layout_pdf_letter,"../layout.dxf",$@)

layout.dxf: $(SRC_DIR)/layout.scad \
	$(SRC_DIR)/util.scad \
	$(SRC_DIR)/spool_core.scad \
	$(SRC_DIR)/parameters.scad \
	$(SRC_DIR)/motor_bracket_2d.scad \
	$(SRC_DIR)/lineroller_D.scad \
	$(SRC_DIR)/lineroller_ABC_winch.scad \
	$(SRC_DIR)/layout.scad
	$(OPENSCAD_BIN) \
		-D twod=true \
		-D mover=false \
		-D mounted_in_ceiling=false \
		-D bottom_triangle=false \
		-o $@ $(SRC_DIR)/$(basename $(notdir $@)).scad

layout_a4.pdf: layout.dxf \
	$(SRC_DIR)/layout.scad \
	$(SRC_DIR)/util.scad \
	$(SRC_DIR)/spool_core.scad \
	$(SRC_DIR)/parameters.scad \
	$(SRC_DIR)/motor_bracket_2d.scad \
	$(SRC_DIR)/lineroller_D.scad \
	$(SRC_DIR)/lineroller_ABC_winch.scad \
	$(SRC_DIR)/layout.scad \
	$(SRC_DIR)/layout_slicer.scad
	$(call make_layout_pdf_a4,"../layout.dxf",$@)

$(STL_DIR)/%.stl: $(SRC_DIR)/beam_slider_ABC.scad \
	$(SRC_DIR)/beam_slider_D.scad \
	$(SRC_DIR)/corner_clamp.scad \
	$(SRC_DIR)/extruder_holder.scad \
	$(SRC_DIR)/Mechaduino_standoff.scad \
	$(SRC_DIR)/gears.scad \
	$(SRC_DIR)/gear_util.scad \
	$(SRC_DIR)/lineroller_ABC_winch.scad \
	$(SRC_DIR)/lineroller_anchor.scad \
	$(SRC_DIR)/lineroller_anchor_template.scad \
	$(SRC_DIR)/lineroller_D.scad \
	$(SRC_DIR)/motor_bracket.scad \
	$(SRC_DIR)/motor_gear.scad \
	$(SRC_DIR)/parameters.scad \
	$(SRC_DIR)/spool_gear.scad \
	$(SRC_DIR)/spool.scad \
	$(SRC_DIR)/spool_core.scad \
	$(SRC_DIR)/spacer.scad \
	$(SRC_DIR)/cable_clamp.scad \
	$(SRC_DIR)/util.scad
	$(OPENSCAD_BIN) -o $@ $(SRC_DIR)/$(basename $(notdir $@)).scad

all: | $(STL_DIR) $(STL_DIR)/beam_slider_ABC.stl \
	$(STL_DIR)/beam_slider_D.stl \
	$(STL_DIR)/corner_clamp.stl \
	$(STL_DIR)/Mechaduino_standoff.stl \
	$(STL_DIR)/extruder_holder.stl \
	$(STL_DIR)/lineroller_ABC_winch.stl \
	$(STL_DIR)/lineroller_anchor.stl \
	$(STL_DIR)/lineroller_anchor_template.stl \
	$(STL_DIR)/lineroller_D.stl \
	$(STL_DIR)/motor_bracket.stl \
	$(STL_DIR)/motor_gear.stl \
	$(STL_DIR)/spool_gear.stl \
	$(STL_DIR)/spool.stl \
	$(STL_DIR)/spool_core.stl \
	$(STL_DIR)/spacer.stl \
	$(STL_DIR)/cable_clamp.stl \
	layout.dxf \
	layout_a4.pdf

$(STL_DIR):
	@echo "Creating STL_DIR $(STL_DIR)"
	mkdir -p $@

$(STL_NEMA23_DIR):
	@echo "Creating STL_NEMA23_DIR $(STL_NEMA23_DIR)"
	mkdir -p $@

.PHONY: all
