# Sliding lower roller

The lower 3 mm axle is carried by two identical printed sliders, one through each frame cheek. Both cheeks have matching vertical guides. The roller gap can vary from 0 to 5 mm; the slider shoulders and bottoms form the end stops. `odometer_roller_gap` previews this motion without changing the frame or slider geometry.

The upper axis is now 43.5 mm above the floor. The lower axis travels from 18.5 mm at zero gap to 13.5 mm at 5 mm gap. This leaves 1 mm beneath the roller at maximum opening. The fixed line guides retain their 45-degree undersides and clear the complete lower-roller travel.

## Print and assembly

From `odometer.scad`, export one **Frame**, two **Lower slider** parts, and one **Lower bearing spacer**. The slider output puts its flat outer flange on the bed; the spacer prints upright. The default slider fit has 0.2 mm clearance on each side in Y and 0.25 mm between the flange and frame. Adjust `odometer_slide_clearance` after checking a printed fit.

The hardware preview uses two 623 bearings, a 45 mm M3 axle or threaded rod, and a washer and nut at each end. Insert the sliders from outside the cheeks, with their pointed ends upward. Put the bearings in the roller and the 7 mm spacer between their inner races, then pass the axle through the sliders and bearings. The sliders' small inner bosses contact the inner races. Tightening the axle must leave the roller free to rotate and the two sliders free to move together; fit the spacer to the actual bearing stack if necessary.

## Extension springs

Each shaft end has two fixed mushroom posts and two pairs of moving eyelets. The posts have 2.4 mm necks and 4 mm retaining heads; the eyelets are 2.2 mm through-holes. There is room for nominal 3–4 mm diameter springs outside the slider flanges. Choose spring hooks that can engage the posts and eyelets; body diameter alone does not establish hook fit.

The upper eyelets give a nominal vertical post-to-eyelet spacing of 7.5–12.5 mm across the travel, and the lower eyelets give 11.5–16.5 mm. These are attachment-center distances, not spring free lengths. Use shorter springs from the available assortment that retain tension at the smallest working gap without overstretching at the largest. Spring force and usable extension still need checking with the actual springs.

Matched springs on the two sides of each slider give balanced loading. The paired posts also leave a choice of attachment position when trying springs. `odometer_show_spring_envelopes` displays 4 mm diameter clearance envelopes at the lower eyelets; these are review aids, not spring models or print parts. Leave this option off for normal exports. The shaft nuts retain the sliders axially; the spring load closes the roller gap, while the line or an external force opens it. There is no screw-adjusted gap lock.

## CAD verification

Review views cover the assembly and print parts, plus the 0, 2.5 and 5 mm gap positions. Frame and moving-part interference is checked separately from intentional stop contact. Rendering and closed-mesh checks do not verify printed fit, spring fatigue, clamping force or measurement accuracy.
