# Compression-spring lower roller

Two identical sliders support the lower 3 mm axle, one in each frame cheek. One **15 mm long, 5 mm outside-diameter compression spring** sits directly below each axle end. The sliders have no side wings, and the frame has no spring posts. Both springs push the roller upward through the same vertical guide arrangement.

## Spring seats and travel

The fixed spring seats are at Z = 1.5 mm. At zero roller gap, the axle is at Z = 18.5 mm and each slider's underside is at Z = 15.5 mm. The spring seats are therefore **14 mm apart**, giving **1 mm compression** from the 15 mm free length.

| Roller gap | Installed spring length | Compression from free length |
| --- | --- | --- |
| 0 mm | 14 mm | 1 mm |
| 2.5 mm | 11.5 mm | 3.5 mm |
| 5 mm | 9 mm | 6 mm |

The springs must permit a 9 mm installed length without coil bind; their spring rate, wire diameter and solid height have not been specified. The preview coil is illustrative and does not establish those properties.

Each upright well has a 5.4 mm bore, giving 0.2 mm radial clearance for a 5 mm spring. Its floor is the lower spring seat, and the slider's flat underside is the upper seat. The well opens into the slider slot, so the spring can be inserted before the slider. The guide cheeks are 7 mm thick to fit the spring pockets. The encoder mounting face and cradle move outward with the thicker right cheek.

`odometer_roller_gap` previews the 0–5 mm travel without changing the frame or slider geometry. The slider roof and bottom provide the end stops. At maximum opening the roller still clears the floor by 1 mm. The fixed line guides retain their 45-degree undersides and clear the whole travel.

## Print and assembly

Export one **Frame**, two **Lower slider** parts, and one **Lower bearing spacer** from `odometer.scad`. The frame and its spring wells print upright. The slider output places its flat outer flange on the bed, with the neck and bearing boss upward. There are no projecting mushroom posts to print or insert.

The hardware preview uses two 623 bearings, a 45 mm M3 axle or threaded rod, and a washer and nut at each end. Put a compression spring into each well. Insert each slider from outside its cheek with the pointed end upward, compressing the spring under its flat bottom. Fit the bearings and the 7 mm spacer inside the roller, then install the axle through both sliders and bearings.

The slider bosses and spacer bear on the bearing inner races. Tightening the axle must leave the roller free to rotate and the sliders free to move together. Fit the spacer to the actual bearing stack if needed. The default slider has 0.2 mm clearance on each side in Y and 0.25 mm clearance between its flange and the frame; adjust `odometer_slide_clearance` after checking the printed fit.

`odometer_spring_diameter` and `odometer_spring_radial_clearance` control the pockets. `odometer_show_springs` shows the illustrative coils, and `odometer_show_spring_envelopes` shows their clearance cylinders. These purchased-part previews are excluded from **Frame** and **Lower slider** exports. Spring load closes the gap; the line or an external force opens it. There is no screw-adjusted gap lock.

## Verification

Review views cover the assembly, print parts and spring-seat sections at 0, 2.5 and 5 mm roller gaps. CAD checks establish seat spacing, clearances and closed meshes. Printed fit, spring force and the actual springs' solid height still need checking on the build.
