include <measured_numbers.scad>
include <design_numbers.scad>
use <parts.scad>
use <placed_parts.scad>
use <render_parts.scad>

// Style:
//  - Global parameters starts with capital letter, others don't

// TODO:
//  - Improve extruder drive and hotend mount.
//    Complete rewrite of those
//    (assembling along z-direction from the beginning)
//    might be worth it...

// Rendering control
render_bottom_plate = false;
render_sandwich     = false;
render_abc_motors   = false;
render_fish_rings   = false;
render_lines        = false;
render_extruder     = true;
render_hotend       = false;
render_ramps        = false;
render_plates       = false;
render_filament     = false;

module full_render(){
  if(render_bottom_plate){
    bottom_plate();
    // For better rendering performance, precompile bottom_plate
    //precompiled("stl/bottom_plate_for_render.stl");
  }
  if(render_sandwich){
    placed_sandwich();
    // For better rendering performance, precompile placed sandwich
    //precompiled("stl/complete_sandwich_for_render.stl");
  }
  if(render_abc_motors){
    placed_abc_motors();
  }
  if(render_fish_rings){
    placed_fish_rings();
  }
  if(render_lines){
    color("green")
    placed_lines();
  }
  if(render_extruder){
    placed_extruder();
  }
  if(render_hotend){
    placed_hotend();
  }
  if(render_ramps){
    placed_ramps();
  }
  if(render_plates){
    placed_plates();
  }
  if(render_filament){
    filament();
  }
}
full_render();

// Use for better rendering performance while working on other part.
module precompiled(s){
    echo("Warning: using precompiled file", s);
    import(s);
}
