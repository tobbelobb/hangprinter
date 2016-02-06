include <measublue_numbers.scad>
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
render_bottom_plate  = true;
render_sandwich      = true;
render_abc_motors    = true;
render_fish_rings    = true;
render_lines         = true;
render_extruder      = true;
render_hotend        = true;
render_ramps         = true;
render_plates        = true;
render_filament      = true;
render_wall_vgrooves = true;

module full_render(){
  if(render_wall_vgrooves){
    placed_wall_vgrooves();
  }

  if(render_bottom_plate){
    color(Printed_color_1)
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
    color("yellow")
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
    color(Printed_color_1)
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
