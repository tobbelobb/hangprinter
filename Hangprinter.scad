include <measured_numbers.scad>
include <design_numbers.scad>
use <parts.scad>
use <placed_parts.scad>
use <render_parts.scad>

// TODO:
//  - Place gatts reliably with screw holes or similar
//  - Place hot end reliably
// Style:
//  - Spaces separate arguments and long words only
//  - Global parameters starts with capital letter, others don't
//  - Modules that are meant as anti-materia starts with capital letter

// Rendering control
render_bottom_plate = true;
render_sandwich     = true;
render_xy_motors    = true;
render_gatts        = false;
render_lines        = false;
render_extruder     = true;
render_hotend       = false;
render_ramps        = false;
render_plates       = false;
render_filament     = true;

module full_render(){
  if(render_bottom_plate){
    bottom_plate();
  }
  if(render_sandwich){
    placed_sandwich();
  }
  if(render_xy_motors){
    placed_xy_motors();
  }
  if(render_gatts){
    placed_gatts();
  }
  if(render_lines){
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
