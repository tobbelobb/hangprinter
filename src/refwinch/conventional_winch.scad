include <conventional_guide/self_reversing_thread_bosl2.scad>
include <../lib/parameters.scad>

rod_l = 42 + 2*4 + 2*b608_width;
rod_d = 8;

self_reversing_grooved_rod(
    rod_d=rod_d,
    rod_l=rod_l,
    stroke=42,
    turns_per_stroke=4,
    cycles=1,
    groove_d=2.2,
    groove_depth=1.35,
    samples_per_turn=120,
    reversal_frac=0.50
);

down(rod_l/2 - b608_width)
  cylinder(d = rod_d + 1, h = 1);
up(rod_l/2 - b608_width - 1)
  cylinder(d = rod_d + 1, h = 1);
