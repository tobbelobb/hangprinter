include <layout_parameters.scad>

a4_width = 210;
a4_length = 297;
margin = 5;
y_overlap = 40;
x_overlap = 40;
page = 1; // To be defined in call via Makefile

x0 = -a4_width*3/2 + x_overlap;
x1 = -a4_width/2;
x2 = a4_width/2 - x_overlap;
y0 = -y_overlap/2;
y1 = -a4_length + y_overlap/2;

//x0 = -(Ext_sidelength+Additional_added_plate_side_length)/2-margin;
//x1 = -a4_width/2;
//x2 = (Ext_sidelength+Additional_added_plate_side_length)/2+margin-a4_width;
//y0 = -a4_length+(Ext_sidelength+Additional_added_plate_side_length)/2+margin;
//y1 = -(Ext_sidelength+Additional_added_plate_side_length)/2- margin + Yshift_top_plate;

difference(){
  translate([0,Yshift_top_plate])
    if(page==1)
      translate([x0, y0])
        square([a4_width, a4_length]);
    else if(page==2)
      translate([x1, y0])
        square([a4_width, a4_length]);
    else if(page==3)
      translate([x2, y0])
        square([a4_width, a4_length]);
    else if(page==4)
      translate([x0, y1])
        square([a4_width, a4_length]);
    else if(page==5)
      translate([x1, y1])
        square([a4_width, a4_length]);
    else if(page==6)
      translate([x2, y1])
        square([a4_width, a4_length]);
    import("../layout.dxf");
}
