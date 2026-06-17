// self_reversing_thread_bosl2.scad
// BOSL2-based self-reversing / diamond helix groove and ridge generator.

include <../../lib/BOSL2/std.scad>
include <../../lib/BOSL2/threading.scad>

// ---------- Small math helpers ----------

function sr_clamp(x, lo, hi) = min(max(x, lo), hi);
function sr_posmod(x, m) = x - floor(x/m)*m;

// Cubic easing only near x=0 and x=1.
// The middle remains exactly linear, so the pitch is constant except
// within reversal_frac of each end of the stroke.
function sr_end_eased01(x, reversal_frac=0.08) =
    let(e = sr_clamp(reversal_frac, 0, 0.49))
    e <= 0 ? x :
    x < e ?
        let(t = x/e) e * (2*t*t - t*t*t) :
    x > 1-e ?
        1 - sr_end_eased01(1-x, e) :
    x;

// One full self-reversing cycle has two half-strokes:
// u = 0..1 goes bottom->top, u = 1..2 goes top->bottom.
function sr_triangle01(u, reversal_frac=0.08) =
    let(v = sr_posmod(u, 2), x = v <= 1 ? v : 2-v)
    sr_end_eased01(x, reversal_frac);

// Centerline point on a cylinder.
// a is in degrees. OpenSCAD trig uses degrees.
function sr_cyl_point(r, a, z) = [r*cos(a), r*sin(a), z];
function sr_cyl_normal(a) = [cos(a), sin(a), 0];

function sr_halfstroke_path(
    r,
    stroke,
    turns_per_stroke,
    half_index=0,
    samples_per_turn=24,
    reversal_frac=0.08,
    phase=0
) =
    let(
        steps = max(8, ceil(abs(turns_per_stroke) * samples_per_turn)),
        up = (half_index % 2) == 0,
        start_turn = half_index * turns_per_stroke
    )
    [
        for (i = [0:steps])
        let(
            q = i / steps,
            // q is local half-stroke progress. Ease it to round the turnarounds.
            qe = sr_end_eased01(q, reversal_frac),
            pos = up ? qe : 1-qe,
            a = phase + 360 * (start_turn + q * turns_per_stroke),
            z = -stroke/2 + stroke * pos
        )
        sr_cyl_point(r, a, z)
    ];

function sr_halfstroke_normals(
    turns_per_stroke,
    half_index=0,
    samples_per_turn=24,
    phase=0
) =
    let(
        steps = max(8, ceil(abs(turns_per_stroke) * samples_per_turn)),
        start_turn = half_index * turns_per_stroke
    )
    [
        for (i = [0:steps])
        let(
            q = i / steps,
            a = phase + 360 * (start_turn + q * turns_per_stroke)
        )
        sr_cyl_normal(a)
    ];

// Returns a circular cutter path suitable for path_sweep().
function sr_circle_profile(d=2, fn=16) = circle(d=d, $fn=fn);

// A ridge profile. The path point is on the cylinder surface at the center of the base.
// +Y points radially outward because we pass radial normals to path_sweep().
function sr_trapezoid_ridge_profile(width=2.4, top_width=0.8, height=1.0) = [
    [-width/2, -height/2],
    [-top_width/2, height/2],
    [ top_width/2, height/2],
    [ width/2, -height/2]
];

// A cutter profile for a flat-bottom-ish groove. The path point is at the cutter center.
// For most prototypes, a circle cutter is safer because it avoids profile orientation surprises.
function sr_rounded_slot_cutter_profile(width=2.4, depth=1.2) = [
    [-width/2, -depth/2],
    [-width/2,  depth/2],
    [ width/2,  depth/2],
    [ width/2, -depth/2]
];

// Sweep one half-stroke with BOSL2 path_sweep().
// shape is a 2D polygon/path, for example sr_circle_profile(d=2).
module sr_halfstroke_sweep(
    shape,
    r,
    stroke,
    turns_per_stroke,
    half_index=0,
    samples_per_turn=24,
    reversal_frac=0.08,
    phase=0,
    caps=true,
    convexity=10
) {
    path = sr_halfstroke_path(
        r=r,
        stroke=stroke,
        turns_per_stroke=turns_per_stroke,
        half_index=half_index,
        samples_per_turn=samples_per_turn,
        reversal_frac=reversal_frac,
        phase=phase
    );
    normals = sr_halfstroke_normals(
        turns_per_stroke=turns_per_stroke,
        half_index=half_index,
        samples_per_turn=samples_per_turn,
        phase=phase
    );

    // method="manual" lets us force the profile's +Y direction to stay radial.
    path_sweep(
        shape,
        path,
        method="manual",
        normal=normals,
        caps=caps,
        convexity=convexity
    );
}

// A union of swept cutters that can be subtracted from a cylinder.
// groove_depth controls how far the circular cutter intrudes into the cylinder.
// For a circular cutter: path radius = rod_r + cutter_r - groove_depth.
module self_reversing_groove_mask(
    rod_d=16,
    stroke=40,
    turns_per_stroke=4,
    cycles=1,
    groove_d=2.2,
    groove_depth=1.25,
    samples_per_turn=28,
    reversal_frac=0.08,
    phase=0,
    cutter_fn=18,
    convexity=20
) {
    cutter_r = groove_d/2;
    path_r = rod_d/2 + cutter_r - groove_depth;

    shape = sr_trapezoid_ridge_profile(width=groove_d/4, top_width=groove_d*2, height=groove_d);
    //shape = sr_circle_profile(d=groove_d, fn=cutter_fn);

    union() {
        for (half = [0 : 2*cycles-1]) {
            sr_halfstroke_sweep(
                shape=shape,
                r=path_r,
                stroke=stroke,
                turns_per_stroke=turns_per_stroke,
                half_index=half,
                samples_per_turn=samples_per_turn,
                reversal_frac=reversal_frac,
                phase=phase,
                caps=true,
                convexity=convexity
            );
        }
    }
}

// A subtractive barrel-cam style self-reversing groove.
module self_reversing_grooved_rod(
    rod_d=16,
    rod_l=50,
    stroke=40,
    turns_per_stroke=4,
    cycles=1,
    groove_d=2.2,
    groove_depth=1.25,
    samples_per_turn=28,
    reversal_frac=0.08,
    phase=0,
    cutter_fn=18,
    rod_fn=96
) {
    difference() {
        cyl(d=rod_d, l=rod_l, $fn=rod_fn);
        self_reversing_groove_mask(
            rod_d=rod_d,
            stroke=stroke,
            turns_per_stroke=turns_per_stroke,
            cycles=cycles,
            groove_d=groove_d,
            groove_depth=groove_depth,
            samples_per_turn=samples_per_turn,
            reversal_frac=reversal_frac,
            phase=phase,
            cutter_fn=cutter_fn
        );
    }
}

// A raised diamond/self-reversing ridge version.
// This is useful if you want a printed external thread rather than a groove.
// For real follower mechanics, the groove version above is usually the better first prototype.
module self_reversing_ridge(
    rod_d=16,
    stroke=40,
    turns_per_stroke=4,
    cycles=1,
    ridge_width=2.4,
    ridge_top_width=0.7,
    ridge_height=1.0,
    samples_per_turn=28,
    reversal_frac=0.08,
    phase=0,
    convexity=20
) {
    shape = sr_trapezoid_ridge_profile(
        width=ridge_width,
        top_width=ridge_top_width,
        height=ridge_height
    );

    union() {
        for (half = [0 : 2*cycles-1]) {
            sr_halfstroke_sweep(
                shape=shape,
                r=rod_d/2,
                stroke=stroke,
                turns_per_stroke=turns_per_stroke,
                half_index=half,
                samples_per_turn=samples_per_turn,
                reversal_frac=reversal_frac,
                phase=phase,
                caps=true,
                convexity=convexity
            );
        }
    }
}

module self_reversing_ridged_rod(
    rod_d=16,
    rod_l=50,
    stroke=40,
    turns_per_stroke=4,
    cycles=1,
    ridge_width=2.4,
    ridge_top_width=0.7,
    ridge_height=1.0,
    samples_per_turn=28,
    reversal_frac=0.08,
    phase=0,
    rod_fn=96
) {
    union() {
        cyl(d=rod_d, l=rod_l, $fn=rod_fn);
        self_reversing_ridge(
            rod_d=rod_d,
            stroke=stroke,
            turns_per_stroke=turns_per_stroke,
            cycles=cycles,
            ridge_width=ridge_width,
            ridge_top_width=ridge_top_width,
            ridge_height=ridge_height,
            samples_per_turn=samples_per_turn,
            reversal_frac=reversal_frac,
            phase=phase
        );
    }
}

// 2D unwrapped centerline for debugging the phase, pitch, and reversal shape.
function sr_unwrapped_halfstroke_path(
    rod_d=16,
    stroke=40,
    turns_per_stroke=4,
    half_index=0,
    samples_per_turn=48,
    reversal_frac=0.08,
    phase=0
) =
    let(
        steps = max(8, ceil(abs(turns_per_stroke) * samples_per_turn)),
        up = (half_index % 2) == 0,
        start_turn = half_index * turns_per_stroke,
        circ = PI * rod_d
    )
    [
        for (i = [0:steps])
        let(
            q = i / steps,
            qe = sr_end_eased01(q, reversal_frac),
            pos = up ? qe : 1-qe,
            turn = start_turn + q * turns_per_stroke,
            z = -stroke/2 + stroke * pos
        )
        [circ * turn, z]
    ];

module show_unwrapped_self_reversing_path(
    rod_d=16,
    stroke=40,
    turns_per_stroke=4,
    cycles=1,
    samples_per_turn=48,
    reversal_frac=0.08,
    width=0.25
) {
    for (half = [0 : 2*cycles-1]) {
        stroke(
            sr_unwrapped_halfstroke_path(
                rod_d=rod_d,
                stroke=stroke,
                turns_per_stroke=turns_per_stroke,
                half_index=half,
                samples_per_turn=samples_per_turn,
                reversal_frac=reversal_frac
            ),
            width=width
        );
    }
}

$fn = 96;

// Main first prototype: subtractive rounded groove.
//self_reversing_grooved_rod(
//    rod_d=8,
//    rod_l=50,
//    stroke=42,
//    turns_per_stroke=4,
//    cycles=1,
//    groove_d=2.2,
//    groove_depth=1.35,
//    samples_per_turn=60,
//    reversal_frac=0.50
//);

// For a raised thread instead:
// self_reversing_ridged_rod(
//     rod_d=16,
//     rod_l=50,
//     stroke=42,
//     turns_per_stroke=4,
//     cycles=1,
//     ridge_width=2.4,
//     ridge_top_width=0.7,
//     ridge_height=1.0,
//     samples_per_turn=30,
//     reversal_frac=0.10
// );

// For debugging the unwrapped path in 2D:
// show_unwrapped_self_reversing_path(
//     rod_d=16,
//     stroke=42,
//     turns_per_stroke=4,
//     cycles=1,
//     reversal_frac=0.10
// );
