# Maslow 4.1 belt odometer: design, setup burden, field experience, and RefWinch lessons

**Status:** 10 September 2026  
**Maslow baseline:** Maslow 4.1 hardware; released firmware v1.24.0, published 3 August 2026. Later open draft work is identified explicitly and is not treated as released functionality.[^release]

## Executive assessment

Maslow 4's most transferable idea is not its AS5600 sensor. It is the decision to measure the moving tensile element directly, after it leaves the variable-radius storage spool. A toothed measuring roller engages the belt's 2 mm pitch, a magnet makes that roller's angle contactless, and the controller converts multi-turn angle to paid-out belt length. This removes spool diameter, winding pattern, gearbox backlash, and motor-shaft motion from the primary length measurement.

That architecture is sound, but Maslow's implementation demonstrates that a direct odometer is a system, not a sensor. Its public 0.01 mm claim closely matches one AS5600 count at the roller; it does not include sensor nonlinearity, magnet alignment, belt pitch, belt stretch, roller engagement, tension-dependent zeroing, frame flex, or kinematic calibration. In public field reports, the most consequential faults are mechanical and integration faults: unsecured or misplaced magnets, the original floating direction pin, unreliable original RJ45 connections, a 4.1 board/bearing clearance short, sticky spools, damaged guards, tangled belts, and force-dependent calibration and scale error.

For RefWinch, the Maslow evidence supports retaining a spool-independent odometer and the current MA600A/JST-GH direction. It does **not** validate the present smooth-roller/round-line interface. Maslow gets positive engagement from belt teeth; RefWinch currently depends on friction while nominally squeezing a 2 mm line through a 1 mm roller gap. The first RefWinch prototype therefore needs to prove line-to-roller fidelity under tension, reversal, contamination, and life cycling. Counting flawless ABZ edges is necessary but cannot reveal line slip.

The highest-value design changes are:

1. make the magnet/shaft/roller/board a factory-assembled, replaceable odometer cartridge with mechanical magnet retention and poka-yoke alignment;
2. add an independent plausibility channel or physical reference so a loose magnet or slipping roller cannot remain a believable position signal;
3. qualify **millimetres of actual line travel**, not just encoder counts, over the full tension/speed/environment envelope;
4. record tension or a defensible tension proxy with length, and keep line elasticity separate from odometer scale calibration;
5. expose field-strength, illegal-quadrature, index, residual, and disagreement diagnostics to production and users.

## 1. What Maslow actually measures

Maslow 4.1 has four identical belt axes. Each stores belt on a central polycarbonate spool driven by a 24 V DC gearmotor through steel drive and idler gears. The outgoing steel-reinforced TPU belt passes between two glass-filled polycarbonate rollers. One roller positively engages the belt teeth and contains a magnet; the adjacent encoder PCB carries an AS5600 on-axis magnetic angle sensor. The motor is controlled until measured belt length follows the kinematic target. Motor current is a second signal used to detect a taut or fully retracted condition, not the primary length signal.[^manual][^kit]

The functional chain is:

> belt teeth → 22-tooth measuring roller → magnet → AS5600 absolute angle → JST-XH cable → I²C multiplexer → ESP32-S3 → software turn counter → millimetres → position controller

This distinction matters. The encoder is not on the motor and does not measure the storage spool. The spool can change effective diameter, wind imperfectly, or move through gear backlash without directly changing the length scale. Conversely, any fault between belt motion and measuring-roller/magnet motion is invisible to the controller because the encoder signal is the feedback truth.

### 1.1 Odometer-related parts

| Element, per belt axis | Current Maslow 4.1 implementation | Function and important constraint |
|---|---|---|
| Tensile element | 14.5 ft, 6 mm-wide 2GT/GT2 steel-reinforced TPU belt; nominal 2 mm pitch | The molded teeth are both power-transmission features and the odometer's linear scale. Published firmware uses an empirically adjusted 1.9988 mm pitch.[^belt][^pitch] |
| Measuring pair | Two glass-filled polycarbonate rollers; firmware geometry specifies 22 teeth on the encoder roller | The toothed roller gives positive engagement. The opposing roller maintains the belt path/contact. |
| Bearings and arm structure | 148ZZ bearings in POM arm halves; the 4.1 kit has 30 bearings overall | Bearing fit, arm closure, and nearby metal set roller alignment and drag. |
| Magnetic target | One small diametrically magnetized encoder magnet glued into a shallow roller recess | Must remain centered, at the correct sensor-side end, and rigidly coupled to the roller. Adhesive is part of the measurement chain. |
| Angle sensor PCB | AS5600-ASOT, 100 nF decoupling, I²C pull-ups, DIR grounded, JST-XH connector in the currently published schematic | The AS5600 is a 12-bit, single-turn absolute angle sensor at fixed I²C address 0x36.[^boards] |
| Sensor interconnect | Four short JST-XH cables to four controller ports | Replaced the original RJ45/Ethernet connectors specifically for dust and vibration reliability.[^changes] |
| Shared controller resources | ESP32-S3 controller and TI TCA9546A four-channel I²C switch in the public controller BOM | Four fixed-address AS5600s are selected one at a time. The firmware uses a 200 kHz bus and a nominal 1 kHz polling scheduler.[^mux] |
| Storage drive | 24 V planetary DC gearmotor, DRV8876 motor driver, steel gears, polycarbonate spool and belt guard | Moves and stores the belt. Its current feedback creates the retract/taut datum. It is not an independent position encoder. |

There is a release-engineering caveat in the public hardware repository: its encoder schematic shows the newer JST-XH/grounded-DIR circuit, while its downloadable encoder BOM still lists the older RJ45 connector, different pull-ups, 120 Ω parts, and an LMV321. The 4.1 product manual and schematic agree on AS5600 + JST-XH, but the public BOM is not a coherent 4.1 manufacturing release.[^boards] A RefWinch release should version-lock schematic, PCB, BOM, firmware configuration, cable drawing, and mechanical datum in one manifest.

### 1.2 Counts, resolution, and accuracy are different quantities

Released firmware v1.24.0 uses:

```text
beltToothSpacing = 1.9988 mm
encoderTeeth     = 22
mmPerRevolution  = 1.9988 × 22 = 43.9736 mm
mmPerCount       = 43.9736 / 4096 = 0.0107357 mm
```

Those values are configurable and the position conversion is exactly the 12-bit cumulative AS5600 count multiplied by millimetres per revolution.[^geometry]

Maslow's statement that it controls belt length to 1/100 mm is therefore a fair shorthand for **digital resolution**. It is not a complete accuracy specification. The AS5600 datasheet specifies 12-bit resolution but up to ±1° integral nonlinearity with a centered magnet. At Maslow's circumference that is about ±0.122 mm of cyclic length error. The error repeats each roller turn rather than accumulating over belt length, but it can bias a stopped measurement depending on roller phase. The specified output noise converts to only about 0.002–0.005 mm RMS, so ordinary sensor noise is much smaller than the maximum cyclic nonlinearity.[^as5600]

The same datasheet calls for 30–90 mT at the die for normal performance, gives a typical 0.5–3 mm air gap, and allows only 0.25 mm axis displacement with a 6 mm magnet. It recommends using AGC to center the magnetic operating margin.[^as5600] Maslow's startup test checks I²C communication and whether a magnet is detected, but released firmware does not appear to qualify AGC, magnitude, eccentricity, angular linearity, or magnet-to-roller rigidity.[^selftest]

### 1.3 How multi-turn length is created

The AS5600 itself reports only 0–4095 within one revolution. Maslow's library polls the angle and accumulates deltas. It recognizes a wrap only when a reading crosses between the high and low quarters of the circle. This works while samples are frequent and direction is unambiguous; it is still a software turn counter, not a true absolute multi-turn sensor.[^unwrap]

Firmware v1.24.0 saves each belt's multi-turn length and current raw angle to nonvolatile memory in selected valid states. At boot it takes the shortest modulo-one-turn angle difference, accepts it only if it is less than a quarter turn, and adjusts the saved length by that fraction.[^persistence] This is a useful recovery feature, but it cannot observe an integer number of roller turns while power is off. One full unobserved turn aliases to no movement—43.9736 mm at the belt—and other large motions can alias into the accepted ±quarter-turn window. Maslow's reliable absolute reference remains the retract-to-taut procedure.

### 1.4 The zero and force reference

`Retract All` gradually drives each spool inward. It stops when either motor current exceeds the configured threshold or three successive current excursions exceed an incremental threshold, logs the pre-zero offset, and resets the cumulative encoder count to zero.[^zero] This is elegant because it needs no limit switch, but zero now depends on:

- spool and bearing friction;
- belt routing and guard contact;
- belt-end seating;
- motor/gear friction and current-sense variation;
- the selected threshold;
- elastic compression/stretch at the mechanical end condition.

The default released threshold is 1300. Maslow's 4.1 upgrade author reports being able to reduce it to 900 after the lower-friction hardware changes and recommends doing so.[^upgrade] The documentation explicitly warns that too little force can give incomplete or inconsistent retraction, while too much is hard on the machine and indirectly raises operating belt tension.[^quickstart]

## 2. What Maslow requires from its producer

The apparent electronic simplicity—one sensor IC and a magnet—creates significant mechanical and production work.

### 2.1 Parts and process control

The producer must control at least the following odometer-critical characteristics:

- belt tooth pitch and its lot-to-lot/tension dependence;
- measuring-roller tooth form, pitch diameter, concentricity, axial play, and molded bearing seats;
- magnet diameter, thickness, diametric magnetization, field strength, bond preparation, cure, centering, and axial gap;
- sensor placement relative to the roller shaft and clearance to bearings/pins/other ferromagnetic parts;
- spool bore/bearing-surface roundness and flash, gear alignment, and guard clearance;
- connector retention and off-board bus integrity under router vibration and conductive/insulating dust;
- current-sense calibration and a safe taut-detection threshold distribution.

Maslow's 4.1 changes are unusually direct evidence of where 4.0 production tolerances and architecture were costly. The producer changed RJ45 to JST-XH, enlarged the guard to keep belt away from drive gears, added bearings on both sides of the idler gear, integrated the idler shaft and gear in steel, precision-cut the linear rods, and changed fasteners that stripped when used with threadlocker.[^changes] The company has also shifted some adhesive work to the factory because shipping liquid glue by air became problematic.[^assembly]

The lesson is not merely to tighten tolerances. The odometer should be designed so ordinary tolerances cannot create believable-but-wrong length. Mechanical datums should locate the sensing center, the magnet should be captured even if its adhesive fails, and any nearby bearing or pin should be unable to touch live PCB conductors throughout the tolerance stack.

### 2.2 Production tests implied by the field failures

A credible end-of-line test for this architecture needs more than “sensor found” and “magnet detected.” For every completed axis, Maslow's experience implies:

1. verify direction polarity and monotonic count in both directions;
2. log raw angle, AGC/magnitude, field-too-weak/strong status, and cyclic angle residual over several slow turns;
3. compare commanded or independently measured line travel to encoder travel over the full stroke;
4. retract–extend–retract under representative tension and bound the residual;
5. shock/vibrate the assembly, then repeat the magnetic and residual tests;
6. test connector/bus error rate with motors and router noise present;
7. verify spool breakaway and running drag, guard clearance, and no belt edge damage;
8. serialize the axis and retain measured scale, cyclic-error, field-margin, current, and residual data.

Maslow publicly described programming and testing hundreds of controller boards and changing packaging after components were damaged in shipment, illustrating that factory and shipping controls are real product requirements for a kit that users assemble.[^factory]

## 3. What Maslow requires from users

### 3.1 One-time arm assembly

The official 4.1 instructions call arm assembly the most difficult part of the build. Odometer-relevant user work includes:

- glue the belt end fully into the spool slot, unless factory-glued;
- glue four magnets into the shallow recesses of four of eight rollers and keep the rollers apart while curing, unless factory-glued;
- seat the encoder PCB on two guide pegs;
- install the motor with threadlocked fasteners and choose its position within available play so the gear train is not too tight;
- set the motor drive-gear gap to roughly an index card and secure its set screw;
- press the required bearings into both arm halves and fit the idler gear and guard;
- feed the belt with teeth in the stated orientation;
- place the magnetic roller on the sensor side, align two roller shafts plus drive and idler shafts, and close the two arm halves without disturbing them;
- adjust the guard if it rubs, then connect four encoder cables to the correct controller ports.[^assembly]

This is a substantial metrology assembly performed by the customer. A roller installed on the wrong side can still look mechanically plausible; an under-glued magnet can pass initial magnet detection; and connector pins sit close enough to a bearing that at least one 4.1 user reported a short after the board shifted.

### 3.2 Frame and geometry prerequisites

The odometers do not by themselves locate the sled. Users must provide four rigid, non-moving anchors and a flat, stiff support surface. Official guidance says the anchors must fit within the available 14.5 ft belt reach and a roughly 5.5 m square, pivot freely on approximately 10 mm/3/8 in smooth pins, have clear sweep space, and avoid vertical play. The surface can be horizontal to about 20° from vertical. Anchors, frame, and work support must withstand pulls up to roughly 40 lbf without significant motion or flex.[^frame]

Anchor XY coordinates, each belt's Z geometry, belt-end extension, arm length, spoilboard thickness, work thickness, and Z position feed the kinematics. A good odometer cannot correct an incorrect anchor plane, a bowing spoilboard, or a frame that moves by millimetres under changing belt load.

### 3.3 Initial reference and calibration

The current documented workflow is:

1. update firmware/UI/configuration and power-cycle;
2. clear the alarm, remove the router bit, and lower/set the Z stop as instructed;
3. enter a rough anchor-to-center distance (`Extend Dist`), orientation, a safe calibration-grid size/point count where applicable, and retraction force;
4. run `Retract All` to bring every belt to the current-defined mechanical datum and zero all four odometers;
5. run `Extend All`; manually pull each belt—often using a rocking/aggressive start followed by steady force—until the controller pays out the requested length;
6. attach all four belts to the anchors;
7. run `Find Anchor Locations`; the sled moves through a grid, repeatedly tensions belts, measures all four lengths, and solves the anchor coordinates;
8. save the resulting configuration and verify tension/position before cutting.[^quickstart]

At each calibration point, v1.24.0 takes six measurement cycles, discards the first two, requires the four retained samples to agree within 2.5 mm in successive comparisons, and averages them. It retries inconsistent points and eventually aborts after repeated failures.[^calcode] The code therefore acknowledges meaningful settling/repeatability effects far above the nominal 0.01 mm count size.

The current Quick Start still tells the user to leave the browser open because calculations occur there, but current firmware documentation and source put the Levenberg–Marquardt anchor solver on the ESP32. The conservative user advice—keep the interface open and supervise the machine—remains sensible, but its published rationale is stale.[^solver]

### 3.4 Recurring setup and recovery

After calibration, the frame coordinates persist until the frame changes or configuration is lost. Each detached/redeployed machine still normally goes through `Retract All → Extend All → attach four belts → Apply Tension`. If a length state is unknown or suspicious, retracting re-establishes zero. Users may need to adjust force, free a sticky spool, clean/reseat a connector, inspect magnet placement, or dismantle an arm.

This makes Maslow portable, but deployment is not “attach and know absolute length.” It is a four-axis referencing operation whose success depends on friction and force thresholds.

## 4. Do Maslow users report odometer-related problems?

**Yes.** The evidence is strong that the original 4.0 connector and DIR-pin designs caused recurring faults, and there are multiple 4.1 reports involving magnet retention/placement, PCB clearance, spool drag, guards, retraction, calibration repeatability, and scale accuracy. The public forum is a troubleshooting venue, so it cannot supply a failure rate or prove that most owners have problems. It does establish failure modes and recurrence.

| Reported failure mode | Public evidence and symptoms | Version/status | Design interpretation |
|---|---|---|---|
| Floating AS5600 DIR input | Maslow's founder states the pin was mistakenly left unconnected; static/humidity could reverse encoder direction. Users saw belts drive the wrong way or unspool. The remedy was a solder bridge or replacement PCB.[^dir] | 4.0 systemic defect; grounded in 4.1 | Never leave configuration pins floating. Test direction after environmental exposure, not only at first power-up. |
| RJ45 dust/vibration/I²C dropout | Users reported dozens to hundreds of failed reads per second and interrupted/wayward jobs. Cleaning, reseating, hot glue, or heat-shrink were interim remedies; the 4.1 JST conversion was explicitly created for this problem.[^rj45] | Mainly 4.0; architecture replaced | Connector choice and off-board bus integrity can dominate sensor reliability. A familiar connector is not automatically a suitable motion connector. |
| Board pins contacting bearing | A 4.1 owner isolated a failing encoder PCB and found the board could shift until underside pins touched the bearing, disturbing multiple I²C channels.[^short] | 4.1 field report, March 2026 | Validate the complete electrical/mechanical clearance stack under vibration. One shorted shared bus endpoint can impair other axes. |
| Magnetic roller on wrong side | The self-test reported “magnet not detected”; disassembly showed the magnet roller facing away from the sensor. Reassembly fixed it.[^placement] | 4.1 field report | Key the roller or make wrong installation impossible; a warning after full assembly is too late. |
| Magnet loose, rotating, or detached | Multiple owners found magnets insufficiently glued, able to rotate, detached onto the sensor, or producing retract offsets. Maslow's founder explains that a slipping magnet reports plausible but false position.[^magnet] | 4.0 and 4.1 reports through 2026 | Adhesive-only torque transfer is a latent common-mode failure. “Magnet present” cannot prove magnet-to-shaft coupling. |
| Sticky/damaged spool and false retract datum | A 4.1 user reported a belt declared tight while visibly slack; another found bent spool teeth. Sanding bearing surfaces or replacing the spool reduced required force from 1100+ to 600 in one report.[^spool] | Continues in 4.1 | Current-based homing confounds end condition with internal friction. Measure/limit drag and add a datum or plausibility test. |
| Belt/guard jam and belt damage | Belts have tangled or been mangled in the idler/guard during calibration. A March 2026 4.1 report needed a 2400 threshold until a cracked guard was replaced and spool flash sanded.[^mangle] | 4.0 and 4.1 | The storage path can invalidate the reference and damage the metrology element even though it is outside the sensor. |
| Force-sensitive calibration/retraction | Documentation and forum troubleshooting repeatedly advise changing retraction force; too low stops early, too high adds load and wear. 4.1 hardware allowed a lower recommended value.[^quickstart][^upgrade] | Current | Homing force is a calibration variable and should be measured in physical units or normalized per axis, not an unexplained raw threshold. |
| Belt pitch and global scale error | Maslow found nominal 2.0000 mm teeth closer to 1.9988 mm and exposed pitch/teeth settings. Using 2.0000 rather than 1.9988 would create about 1.2 mm scale error over 2 m.[^pitch] | Current default improved; lot/load dependence remains | Characterize the real metrology element by lot and operating load. Kinematic self-consistency can hide a wrong physical scale. |
| Belt stretch and direction/position-dependent accuracy | A detailed community test estimated roughly 1% strain per 5 kg and reproduced about 6 mm of a measured 1200 mm move error. Another 4.1 grid test began after roughly 1/4 in errors on full-sheet panels. Methods were useful but not laboratory metrology.[^stretch][^xy] | Current/open engineering issue | Paid-out length and taut geometric span differ. Force varies with pose, motion direction, friction, and cutting load, so a constant scale factor is incomplete. |
| Limited observability | Gross I²C loss and >15 mm servo error can stop the machine, but magnet slip and line/roller slip can remain plausible. Current open PRs add belt-stretch compensation and target-versus-measured/diagonal length diagnostics.[^drafts] | Released detection is partial; PRs are draft/open | Diagnostics added late are evidence that target, measurement, load, raw signal, and independent geometry should be first-class telemetry from the start. |

### 4.1 What improved in 4.1

Maslow 4.1 is not simply the same setup with a new label. The JST-XH transition removes the best-documented electrical reliability weakness; grounded DIR removes the direction ambiguity; added idler bearings and integrated shaft improve drivetrain consistency; and enlarged guards address belt/gear separation. The producer also moved some gluing to the factory.[^changes][^assembly]

The remaining 2025–2026 reports show that the architecture is not self-validating. A better connector cannot detect a loose magnet, positive tooth engagement cannot eliminate elastic stretch, and the AS5600's magnet flag cannot prove mechanical coupling. Spool friction can still masquerade as a retract endpoint, and at least one 4.1 clearance stack permitted a board-to-bearing short.

### 4.2 What cannot be concluded

The forum does not give shipped-unit counts by revision, warranty data, controlled reproduction rates, or a random sample. It would be incorrect to call Maslow 4.1 broadly unreliable from these threads. The defensible conclusion is narrower: the listed modes have occurred in real assemblies, several recur across owners and years, and Maslow itself redesigned around the most systemic ones.

## 5. Error budget implications for RefWinch

### 5.1 Maslow error stack

| Layer | Scale/behavior | Accumulates with length? | Maslow handling |
|---|---:|---|---|
| AS5600 quantization | 0.01074 mm/count | No | High count resolution |
| AS5600 specified centered-magnet INL | up to about ±0.122 mm equivalent | Cyclic each 43.97 mm turn | Not explicitly calibrated in released firmware |
| Magnetic eccentricity/gap/retention | assembly-dependent | Usually cyclic or discontinuous | Presence test; user glue and alignment |
| Mean belt pitch | 1.9988 mm current default vs 2 mm nominal | Yes, scale error | Configurable constant |
| Local pitch variation/tooth engagement | belt/roller dependent | Partly averages; can be local | No explicit per-axis map |
| Belt elastic strain and creep | load, length, material, history, temperature | Yes and pose-dependent | No released compensation; draft PR exists |
| Retract zero | force/friction dependent | Offset until next reference | Current-threshold homing every setup |
| Frame/anchor/Z geometry | structure and setup dependent | Converts length error nonlinearly to XY | Multi-point anchor calibration |

Maslow's calibration can make its internal belt-to-geometry model self-consistent while the physical scale remains wrong. The project's own explanation is telling: if the software calls 125 teeth “250 mm,” commanding 125 teeth back will reproduce the same internal point even if the real length is not exactly 250 mm.[^pitch] RefWinch qualification therefore needs an external, SI-traceable length reference.

### 5.2 RefWinch's present architecture

The current RefWinch model uses two smooth 25 mm-diameter, 5 mm-wide rollers on B623 bearings, fixed at 26 mm center distance, with a nominal 2 mm line. That leaves a nominal 1 mm surface gap: a 1 mm geometric interference with an undeformed 2 mm circular line. One upper roller carries a shaft stub and a placeholder 6 × 2.5 mm magnet; a 28 × 12 mm MA600A board sits outside the frame at a planned 2 mm gap. The MA600A first article exposes A/B/Z through a locking six-pin JST-GH connector and deliberately keeps programming SPI on test pads.[^refmodel][^refboard]

For a 25 mm ideal rolling diameter:

```text
nominal travel/revolution = π × 25 = 78.5398 mm
factory-default 512 PPR, x4 edges = 0.03835 mm/edge
4096 PPR, x4 edges              = 0.00479 mm/edge
```

These are count increments, not proven line resolution. The MA600A is a stronger fit than the AS5600 for the current off-axis/orbiting-magnet geometry, and native ABZ avoids Maslow's shared fixed-address I²C bus. Its Z pulse also provides a once-per-revolution phase check. None of those advantages proves that the smooth upper roller tracks round line without creep or slip.

The most important non-transferable difference is:

- **Maslow:** belt tooth pitch is a positive, manufactured linear scale; the roller cannot continuously creep without climbing teeth.
- **RefWinch:** a smooth, round, compliant line is pinched between smooth rollers; traction depends on compression, friction, contamination, line diameter, tension, bend history, roller finish, alignment, and bearing/frame compliance.

Increasing MA600A PPR cannot reduce this mechanical uncertainty. It can merely report the wrong roller motion more finely.

## 6. Recommended RefWinch decisions

### P0 — before calling the odometer geometry viable

1. **Measure line travel against an external reference.** Expand the existing first-article checklist beyond 100-revolution edge integrity. Test at least 3–5 m of actual line travel in both directions against a calibrated linear reference while controlling tension. Report slope, offset, cyclic residual, hysteresis, reversal dead travel, and return-to-reference residual.

2. **Separate four transfer functions.** Qualify (a) magnet → MA600A angle, (b) roller/shaft → angle, (c) line → roller rotation, and (d) paid-out line → taut geometric span. A single end-to-end calibration can hide which layer failed.

3. **Mechanically capture the magnet.** Use a pocket, shoulder, cap, keyed carrier, overmold, or other positive retention so loss of adhesive cannot allow rotation or escape. Adhesive may suppress rattle; it should not be the sole torque path. Make orientation and sensor-side placement impossible to reverse.

4. **Add independent plausibility.** At minimum compare odometer motion with collector/motor motion and tension/current state. Prefer an independent motor/spool encoder or a physical index/reference that can detect a believable but uncoupled odometer. The channels need not have equal accuracy; they need different failure modes.

5. **Use the MA600A diagnostics and ABZ structure.** Production firmware should record field/signal-quality diagnostics, detect illegal quadrature transitions, verify direction, count Z-to-Z edges, and alarm on missing/extra edges or changing index phase. This catches electrical and magnetic faults, though not smooth line slip.

6. **Replace raw-force zeroing with a characterized reference strategy.** If RefWinch uses current/tension to home, calibrate the threshold per axis in physical terms, detect friction separately, bound approach speed, and verify the result with an independent datum or repeat approach. Do not let a sticky spool look identical to a hard endpoint.

### P1 — mechanical/product architecture

7. **Make an odometer cartridge.** Preassemble and test the rollers, bearings, shaft, magnet, board, and connector as one replaceable unit. The user should route line through a keyed path, not perform a magnetic encoder alignment during machine assembly.

8. **Revisit the line-contact geometry.** Evaluate controlled wrap on one metrology roller, a compliant/preloaded idler, a line-compatible groove, and surface options. Optimize for repeatable traction at low line damage, not maximum squeeze. The current fixed 1 mm gap for nominal 2 mm line makes diameter/tolerance/compression a first-order variable.

9. **Keep JST-GH, but qualify the whole link.** The locking connector is directionally aligned with Maslow's 4.1 lesson. The present unbuffered 3.3 V ABZ cable still needs worst-length tests for edge shape, motor/router EMI, ESD, hot-plugging, and receiver thresholds. Add source damping, protection, differential signaling, or a local receiver only if measurement shows it is needed.

10. **Design explicit clearance and magnetic zones.** Tolerance-stack the board, live pins/pads, bearings, steel fasteners, and shaft in all allowed positions. Inspect field margin with the final steel hardware installed, not with a bare board and hand-held magnet.

11. **Treat line as a calibrated component.** Specify material, construction, nominal diameter, finish, minimum bend radius, batch, preconditioning, and allowable wear. Measure scale and elastic behavior per lot. A replaceable line should either carry its calibration or trigger a guided recalibration.

### P2 — controls, calibration, and user experience

12. **Persist absolute state conservatively.** ABZ is incremental. On power loss, mark multi-turn length unknown unless a separate absolute reference proves otherwise. The Z pulse verifies phase, not revolution count. Avoid modulo-one-turn restoration assumptions.

13. **Model load explicitly.** Log length synchronously with tension/load. Distinguish relaxed paid-out length from loaded geometric span. If compensation is needed, identify stiffness, creep, and hysteresis from data instead of letting a kinematic solver absorb them into anchor coordinates or scale.

14. **Give users an automated confidence test.** A preflight should move through a small safe reference cycle, compare both sensing channels, check Z periodicity and field margin, measure return residual, and state which subsystem is suspect. “Encoder connected” and “magnet present” are not enough.

15. **Make calibration observable and versioned.** Show raw counts, millimetres, target, disagreement, tension/current, field quality, index count, and reason for rejection. Save the firmware version, mechanical revision, line lot, calibration constants, and acceptance results together.

## 7. RefWinch validation matrix suggested by the Maslow evidence

| Test | Variables | Required observations | Faults it can expose |
|---|---|---|---|
| Magnetic bench characterization | planned 4–12 mm orbit/radial geometry, 2 mm nominal gap, steel hardware, temperature | field diagnostics, A/B phase, Z phase, counts/rev, cyclic angular residual | weak/strong field, eccentricity, magnetic interference, missed edges |
| External linear scale | 0–full intended travel, both directions, several stop phases | measured line travel vs counts; slope and residual vs roller phase | wrong effective diameter, runout, sensor INL, scale error |
| Tension sweep | minimum slack-management load through maximum service load | scale, hysteresis, slip threshold, line strain | pinch sensitivity, elastic stretch, micro-slip |
| Reversal and dithering | low/high speed, sub-revolution reversals, repeated direction changes | dead travel, illegal transitions, return residual | backlash in shaft coupling, rolling creep, missed quadrature |
| Power interruption | stationary and deliberate off-power movements from fractions to multiple turns | recovered/invalid state and alarm behavior | false multi-turn restoration |
| Contamination | dust, chips, lubricant migration, humidity; clean/dirty cycles | scale, slip, signal quality, bearing drag | friction change, optical-like fouling of mechanics, connector faults |
| Vibration/shock | winch/router spectrum and shipping shocks | magnet/index phase, connector errors, clearances, residual | adhesive failure, board motion, pin/bearing contact |
| Life test | representative loaded travel and reversals through target service life | drift, line/roller wear, debris, bearing torque, calibration change | wear-out and maintenance interval |
| Cross-channel fault injection | loose magnet surrogate, forced roller slip, disconnected/noisy A/B, sticky collector | detection latency and safe response | believable-but-wrong feedback and common-mode gaps |

Acceptance limits should be derived from RefWinch's line-length and end-effector error allocation. Set separate limits for quantization, cyclic error, linear scale, hysteresis, return residual, missed-count probability, and fault-detection latency; do not collapse them into one “encoder accuracy” number.

## 8. Bottom line

Maslow 4.1 validates the broad choice to meter the tensile element downstream of the storage spool. It also shows the cost of making the odometer the only trusted position channel. Its recurring problems concentrate at interfaces—magnet-to-roller, roller/belt-to-spool mechanics, PCB-to-bearing clearance, cable-to-bus reliability, and current threshold-to-physical datum—rather than in the 12-bit angle conversion itself.

For RefWinch, the current MA600A board is not the obvious weakness. The unresolved risks are the smooth-line contact, magnet attachment, multi-turn truth after power loss, and lack of an independent way to reject plausible odometer motion. Prototype effort should now move from PCB resolution toward instrumented line metrology and fault detection. If the smooth-roller transfer proves stable over the real envelope, RefWinch can keep the spool-independent benefit without inheriting Maslow's toothed-belt constraint. If it does not, the correction is mechanical—not more encoder counts.

## Sources

[^release]: MaslowCNC, [Maslow 4 firmware releases](https://github.com/MaslowCNC/Maslow_4/releases), v1.24.0 marked latest and released 3 August 2026.
[^manual]: MaslowCNC, [Maslow 4/4.1 Wisdom Manual, “How does Maslow4 work?”](https://documentation.maslowcnc.com/MaslowCNC_Wisdom_Manual.html#how-does-maslow4-work), describing four steel-reinforced belts, toothed rollers, magnetic encoders, 24 V gearmotors, and current feedback.
[^kit]: MaslowCNC, [Maslow 4/4.1 Wisdom Manual, kit inventory](https://documentation.maslowcnc.com/MaslowCNC_Wisdom_Manual.html#whats-in-the-maslow41-kit), listing AS5600/JST-XH boards and cables, rollers, bearings, spools, belts, motors, gears, and magnets.
[^belt]: Maslow CNC Forums, [Maslow 4 technical wiki](https://forums.maslowcnc.com/t/maslow4-technical-wiki/19993), describing the 2GT/GT2, 6 mm steel-reinforced belt and published belt characteristics.
[^pitch]: Maslow CNC Forums, Barbour Smith and community, [“Today's email Re: Assumptions”](https://forums.maslowcnc.com/t/todays-email-re-assumptions/22174), discussing the empirical 1.9988 mm pitch and the distinction between belt teeth and real-world millimetres.
[^boards]: MaslowCNC, [public Boards repository](https://github.com/MaslowCNC/Boards), especially [encoder schematic](https://github.com/MaslowCNC/Boards/blob/main/Schematic_Encoder-Board.svg), [encoder BOM](https://github.com/MaslowCNC/Boards/blob/main/BOM_Encoder-Board.csv), and [controller BOM](https://github.com/MaslowCNC/Boards/blob/main/BOM_Five-Motor-Control-Board.csv).
[^changes]: MaslowCNC, [“What's New in Maslow 4.1?”](https://www.maslowcnc.com/whats-new-in-maslow-41), documenting JST-XH, guard, idler bearing/shaft, fastener, and rod changes and their motivations.
[^mux]: MaslowCNC, [v1.24.0 encoder initialization and polling](https://github.com/MaslowCNC/Maslow_4/blob/v1.24.0/firmware/FluidNC/src/Maslow/Maslow.cpp#L21-L78) and [failure handling](https://github.com/MaslowCNC/Maslow_4/blob/v1.24.0/firmware/FluidNC/src/Maslow/Maslow.cpp#L321-L375).
[^geometry]: MaslowCNC, [v1.24.0 default belt geometry](https://github.com/MaslowCNC/Maslow_4/blob/v1.24.0/firmware/FluidNC/data/maslow.yaml#L65-L66) and [count-to-length conversion](https://github.com/MaslowCNC/Maslow_4/blob/v1.24.0/firmware/FluidNC/src/Maslow/MotorUnit.cpp#L285-L288).
[^as5600]: ams OSRAM, [AS5600 datasheet, v1-06](https://look.ams-osram.com/m/7059eac7531a86fd/original/AS5600-DS000365.pdf), pp. 8, 30–33: magnetic/system characteristics, direction, diagnostics, magnet placement, field and air-gap guidance.
[^selftest]: MaslowCNC, [v1.24.0 motor/encoder/magnet self-test](https://github.com/MaslowCNC/Maslow_4/blob/v1.24.0/firmware/FluidNC/src/Maslow/MotorUnit.cpp#L48-L80).
[^unwrap]: MaslowCNC, [v1.24.0 modified AS5600 cumulative-position code](https://github.com/MaslowCNC/Maslow_4/blob/v1.24.0/firmware/FluidNC/src/Maslow/AS5600.cpp#L429-L467); upstream library guidance also notes that cumulative position requires sufficiently frequent polling: [Rob Tillaart AS5600 library](https://github.com/RobTillaart/AS5600#cumulative-position).
[^persistence]: MaslowCNC, [v1.24.0 belt-position save/restore](https://github.com/MaslowCNC/Maslow_4/blob/v1.24.0/firmware/FluidNC/src/Maslow/Maslow.cpp#L604-L930).
[^zero]: MaslowCNC, [v1.24.0 retract, current-threshold pull-tight, and zero logic](https://github.com/MaslowCNC/Maslow_4/blob/v1.24.0/firmware/FluidNC/src/Maslow/MotorUnit.cpp#L201-L246).
[^upgrade]: MaslowCNC, [Maslow 4.1 Upgrade Guide](https://www.maslowcnc.com/41-upgrade-instructions), including the post-upgrade 900 force recommendation.
[^quickstart]: MaslowCNC, [Maslow 4 Quick Start Guide](https://documentation.maslowcnc.com/QuickStart.html), covering retract/extend, manual pulling, zero restoration, force adjustment, anchor finding, and supervision.
[^assembly]: MaslowCNC, [Maslow 4.1 arm assembly instructions](https://documentation.maslowcnc.com/assembling-the-arms-4-1/), including factory/user gluing, roller-magnet alignment, board pegs, bearings, gear clearance, guard adjustment, and arm closure.
[^frame]: MaslowCNC, [Frame Library requirements](https://github.com/MaslowCNC/Maslow_4/blob/Maslow-Main/docs/FrameLibrary.md#frame-requirements), covering belt reach, anchors, planes, rigidity, flatness, force, angle, and edge support.
[^calcode]: MaslowCNC, [v1.24.0 repeated-measurement acceptance and averaging](https://github.com/MaslowCNC/Maslow_4/blob/v1.24.0/firmware/FluidNC/src/Maslow/Calibration.cpp#L1773-L1865).
[^solver]: MaslowCNC, [Calibration simulator documentation](https://documentation.maslowcnc.com/calibration-simulation/README.html), stating that current anchor-solving math lives in firmware rather than the web UI.
[^factory]: MaslowCNC, [“Bug Fixes, Testing Boards, Packing Boxes”](https://www.maslowcnc.com/weekly-update/2024/3/20/bug-fixes-testing-boards-packing-boxes), describing board programming/testing, rejected boards, shipping damage, and packaging changes.
[^dir]: Barbour Smith, Maslow CNC Forums, [“Soldering Floating Encoder Board Pin”](https://forums.maslowcnc.com/t/soldering-floating-encoder-board-pin/21837), 12 July 2024; see also a later [belt-unspooling report](https://forums.maslowcnc.com/t/belt-unspooling/23672).
[^rj45]: Maslow CNC Forums, [“Failure on Top Left encoder, failed to read 123 times in the last second”](https://forums.maslowcnc.com/t/failure-on-top-left-encoder-failed-to-read-123-times-in-the-last-second/23323) and [“Jogging off path mid project”](https://forums.maslowcnc.com/t/jogging-off-path-mid-project/23685), February–April 2025.
[^short]: Maslow CNC Forums, [“Encoder I2C Error”](https://forums.maslowcnc.com/t/encoder-i2c-error/25637), March 2026.
[^placement]: Maslow CNC Forums, [“Magnet not detected”](https://forums.maslowcnc.com/t/magnet-not-detected/24599), July 2025.
[^magnet]: Maslow CNC Forums, [“Accuracy and tuning”](https://forums.maslowcnc.com/t/accuracy-and-tuning/25264), December 2025; [“4.1 Calibration Issues and Questions”](https://forums.maslowcnc.com/t/4-1-calibration-issues-and-questions/23825?page=5), April 2025; and [“Maslow4 breaking itself during jog”](https://forums.maslowcnc.com/t/maslow4-breaking-itself-during-jog/25580?page=2), March 2026.
[^spool]: Maslow CNC Forums, [“Retracting Belt Issues”](https://forums.maslowcnc.com/t/retracting-belt-issues/25598), March 2026.
[^mangle]: Maslow CNC Forums, [“Belt got mangled during calibration”](https://forums.maslowcnc.com/t/belt-got-mangled-during-calibration/20269), with reports from March 2024 and March 2026.
[^stretch]: Maslow CNC Forums, [“X & Y Accuracy Analysis: Belt Stretch”](https://forums.maslowcnc.com/t/x-y-accuracy-analysis-belt-stretch/23996), May–June 2025. The author explicitly describes the initial force/extension apparatus as not highly accurate.
[^xy]: Maslow CNC Forums, [“X & Y Accuracy Analysis”](https://forums.maslowcnc.com/t/x-y-accuracy-analysis/23816), April–May 2025.
[^drafts]: MaslowCNC, open draft work as of 10 September 2026: [PR #1060, belt-stretch compensation](https://github.com/MaslowCNC/Maslow_4/pull/1060), [PR #1068, target/measured belt diagnostics](https://github.com/MaslowCNC/Maslow_4/pull/1068), and [PR #1074, diagonal belt-pair measurement](https://github.com/MaslowCNC/Maslow_4/pull/1074).
[^refmodel]: Hangprinter repository, [`odometer.scad`](./odometer.scad), current RefWinch mechanical odometer model.
[^refboard]: Hangprinter repository, [MA600A RefWinch Encoder README](./ma600a_encoder_breakout/README.md), [design decisions](./ma600a_encoder_breakout/docs/design-decisions.md), and [v0.3 pre-fabrication review](./ma600a_encoder_breakout/release/Design-review.md).
