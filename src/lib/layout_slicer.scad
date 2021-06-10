include <parameters.scad>


a4_width = 210;
a4_length = 297;
margin = 5;
y_overlap = 40;
x_overlap = 40;
page = 1; // To be defined in call via Makefile
//all = true; // Used only for quick visual double-checking
all = false;
layout_file = "../../layout.dxf";

x0 = -a4_width*2 + x_overlap;
x1 = -a4_width;
x2 = -x_overlap;
x3 = a4_width - 2*x_overlap;
y0 = a4_length-y_overlap/2;
y1 = -0*a4_length + y_overlap/2;

module crosshairs(){
  translate([-0.05+x_overlap/2, 0])
    square([0.1, a4_length]);
  translate([-0.05+a4_width-x_overlap/2, 0])
    square([0.1, a4_length]);
  translate([0, -0.05 + y_overlap/2])
    square([a4_width, 0.1]);
  translate([0, -0.05 + a4_length - y_overlap/2])
    square([a4_width, 0.1]);
}

module page(){
  difference(){
    square([a4_width, a4_length]);
    crosshairs();
  }
}

module page_tr(){
  if(page==1 || all)
    translate([x1, y0+Yshift_top_plate])
      difference(){
        children(0);
        translate([30,a4_length-40])
          text("Top left", size=15);
      }
  if(page==2 || all)
    translate([x2, y0+Yshift_top_plate])
      difference(){
        children(0);
        translate([58,a4_length-40])
          text("Top center", size=15);
      }
  if(page==3 || all)
    translate([x3, y0+Yshift_top_plate])
      difference(){
        children(0);
        translate([103,a4_length-40])
          text("Top right", size=15);
      }
  if(page==4 || all)
    translate([x1, y1+Yshift_top_plate])
      difference(){
        children(0);
        translate([30,30])
          text("Bottom left", size=15);
      }
  if(page==5 || all)
    translate([x2, y1+Yshift_top_plate])
      difference(){
        children(0);
        translate([43,30])
          text("Bottom center", size=15);
      }
  if(page==6 || all)
    translate([x3, y1+Yshift_top_plate])
      difference(){
        children(0);
        translate([73,30])
          text("Bottom right", size=15);
      }
}

//page_tr()
//  page();
//  rotate([0,0,90])
//import(layout_file);
layout_slice();
module layout_slice(){
  difference(){
    page_tr()
      page();
    rotate([0,0,90])
      import(layout_file);
  }
  // Add back the crosshairs that were diffed out
  intersection(){
    rotate([0,0,90])
      import(layout_file);
    page_tr()
      crosshairs();
  }
}

