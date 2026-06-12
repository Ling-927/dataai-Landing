// ============================================================
// DEFENDER - Stone Pillar Enclosure
// Final Year Project — Raspberry Pi 4 + Pi Camera V3 Housing
// ============================================================
// Description : Parametric stone pillar aesthetic enclosure
//               with Pi Camera V3 mount, RPi4 housing,
//               dual-fan ventilation, hex grilles, cable
//               management trunking, and M4 base mounting.
//               Designed for FDM printing as 4 separate parts.
// Units       : Millimeters (mm)
// Render      : F5 = preview,  F6 = full render for STL export
// Export STL  : Set PART variable (see below), then F6 + Export
// ============================================================

// ============================================================
// GLOBAL RESOLUTION
// ============================================================
$fn = 64;   // Facets for circles/cylinders (increase for smoother curves)

// ============================================================
// MASTER PARAMETRIC DIMENSIONS
// ============================================================
total_w     = 120;   // Overall enclosure width  (X axis)
total_d     = 80;    // Overall enclosure depth  (Y axis)
total_h     = 300;   // Overall enclosure height (Z axis)
wall_t      = 3;     // Wall thickness
chamfer     = 4;     // Edge bevel / chamfer size on outer corners

// ============================================================
// VERTICAL SECTION HEIGHTS  (must sum to total_h = 300)
// ============================================================
cable_h     = 50;    // Bottom:  cable management trunking section
rpi_h       = 110;   // Middle:  Raspberry Pi 4 housing section
cam_h       = 90;    // Top:     camera + visor section
top_cap_h   = 50;    // Cap:     solid top cap (cable_h+rpi_h+cam_h+top_cap_h = 300)

// ============================================================
// STONE TEXTURE PARAMETERS
// ============================================================
groove_d    = 0.8;   // Depth of each horizontal stone joint groove
groove_w    = 1.4;   // Width (height in Z) of each groove line
groove_step = 20;    // Vertical spacing between grooves (simulates block height)

// ============================================================
// RASPBERRY PI 4 PCB PARAMETERS
// ============================================================
rpi_w       = 85;    // RPi4 PCB width
rpi_d       = 56;    // RPi4 PCB depth
rpi_pcb_t   = 1.6;   // PCB thickness
rpi_clear   = 22;    // Clearance above PCB for tallest component (USB/GPIO)
rpi_standoff= 5;     // Standoff height below PCB

// RPi4 standard mounting hole pattern: 58mm x 49mm
rpi_mnt_x   = 58 / 2;
rpi_mnt_y   = 49 / 2;

// ============================================================
// FAN PARAMETERS  (two 40 mm fans, side by side on front face)
// ============================================================
fan_size    = 40;    // Fan frame side length
fan_hole_r  = 17;    // Airflow opening radius
fan_gap     = 6;     // Gap between the two fan frames
fan_screw_d = 3.2;   // Fan corner mounting screw hole diameter (M3)

// ============================================================
// HEX VENTILATION GRILLE PARAMETERS (side walls)
// ============================================================
hex_r       = 4;     // Hexagon circumradius
hex_gap     = 1.5;   // Material gap between adjacent hexagons
hex_rows    = 4;     // Rows of hexagons per grille
hex_cols    = 3;     // Columns of hexagons per grille

// ============================================================
// PI CAMERA V3 PARAMETERS
// ============================================================
cam_lens_d  = 12;    // Lens cutout diameter (12 mm per Pi Camera V3 spec)
cam_pcb_w   = 25;    // Camera PCB width
cam_pcb_d   = 24;    // Camera PCB depth
cam_pocket  = 3;     // Depth of PCB seating pocket behind front wall
cam_z_offset= 40;    // Height of lens hole above start of camera section

// Protective visor / hood above the camera lens
visor_proj  = 20;    // How far the visor extends forward (Y direction)
visor_t     = 5;     // Visor slab thickness
visor_angle = 10;    // Downward tilt of visor (degrees) for rain runoff

// ============================================================
// CABLE MANAGEMENT PARAMETERS
// ============================================================
cable_slot_w= 20;    // Width of each cable exit slot
cable_slot_h= 14;    // Height of each cable exit slot
num_slots   = 3;     // Number of cable exit slots on front face

// ============================================================
// M4 BASE MOUNTING HOLES (pole / wall mount)
// ============================================================
m4_d        = 4.4;   // M4 clearance hole diameter
m4_boss_od  = 10;    // Boss outer diameter
m4_boss_h   = 8;     // Boss height above base
m4_inset_x  = 12;    // X inset from outer wall centre to boss centre
m4_inset_y  = 12;    // Y inset from outer wall centre to boss centre

// ============================================================
// PART SELECTOR — change this value, then render (F6) + Export STL
//   0 = Full assembly (all parts, exploded for overview)
//   1 = Front Shell  (print upright, needs supports for visor + fans)
//   2 = Back Shell   (print upright)
//   3 = Camera Bracket (print flat)
//   4 = Cable Cover  (print upright)
// ============================================================
PART = 0;

// ============================================================
// ============================================================
//                    UTILITY MODULES
// ============================================================
// ============================================================

// --- Chamfered (beveled) box, centered at origin -----------
// Uses Minkowski with an octahedron to bevel all 12 edges.
module chamfered_box(w, d, h, c) {
    minkowski() {
        cube([w - 2*c, d - 2*c, h - 2*c], center=true);
        sphere(r=c, $fn=8);  // $fn=8 keeps the bevel crisp (faceted)
    }
}

// --- Solid box with Z=0 at its base ------------------------
module zbox(w, d, h) {
    translate([0, 0, h/2]) cube([w, d, h], center=true);
}

// --- Single flat-top hexagonal prism -----------------------
module hex_prism(r, h) {
    cylinder(r=r, h=h, $fn=6);
}

// --- Hexagonal grid cutout array ---------------------------
// Generates a cols x rows hexagonal grid centred at origin,
// ready to be subtracted from a wall.
module hex_grid(cols, rows, r, gap, depth) {
    sx = r * 2 + gap;
    sy = r * sqrt(3) + gap;
    for (row = [0 : rows - 1]) {
        for (col = [0 : cols - 1]) {
            ox = (row % 2 == 1) ? sx / 2 : 0;
            translate([
                col * sx + ox - (cols - 1) * sx / 2,
                row * sy - (rows - 1) * sy / 2,
                0
            ])
            hex_prism(r, depth + 1);
        }
    }
}

// --- Horizontal stone groove lines on a face ---------------
// Subtracts horizontal channels into a face lying in the XZ plane.
// Call this while the face normal is pointing in +Y (front face).
module stone_grooves_xz(face_w, face_h, depth, gw, step) {
    num = floor(face_h / step);
    for (i = [1 : num]) {
        translate([0, -depth / 2, i * step - face_h / 2])
            cube([face_w + 2, depth, gw], center=true);
    }
}

// --- M4 mounting boss with through-hole --------------------
module m4_boss(h) {
    difference() {
        cylinder(d=m4_boss_od, h=h);
        cylinder(d=m4_d, h=h + 1);
    }
}

// --- 40 mm fan cutout (circle + 4 corner screw holes) ------
// Subtract this from a wall to create a fan mounting opening.
module fan_cutout(wall_thickness) {
    // Main airflow hole
    cylinder(r=fan_hole_r, h=wall_thickness + 2, center=true);
    // Four corner screw holes
    co = fan_size / 2 - 4;
    for (sx = [-1, 1]) for (sy = [-1, 1]) {
        translate([sx * co, sy * co, 0])
            cylinder(d=fan_screw_d, h=wall_thickness + 2,
                     center=true, $fn=16);
    }
}

// ============================================================
// ============================================================
//                 SECTION MODULES
// Each section contributes its own interior features.
// All sections share the outer shell from outer_shell().
// ============================================================
// ============================================================

// ============================================================
// OUTER PILLAR SHELL
// Creates the full-height hollow chamfered rectangular tube
// with stone groove texture on all four faces.
// ============================================================
module outer_shell() {
    difference() {
        // Chamfered outer solid
        translate([0, 0, total_h / 2])
            chamfered_box(total_w, total_d, total_h, chamfer);

        // Hollow out interior (open top for assembly access)
        translate([0, 0, wall_t + total_h / 2])
            cube([
                total_w - 2 * wall_t,
                total_d - 2 * wall_t,
                total_h + 1
            ], center=true);

        // --- Stone groove texture: FRONT face (+Y) ---
        translate([0, total_d / 2, total_h / 2])
            stone_grooves_xz(total_w, total_h,
                             groove_d, groove_w, groove_step);

        // --- Stone groove texture: BACK face (-Y) ---
        // Mirror: rotate 180 deg around Z so grooves still go inward
        translate([0, -total_d / 2, total_h / 2])
        rotate([0, 0, 180])
            stone_grooves_xz(total_w, total_h,
                             groove_d, groove_w, groove_step);

        // --- Stone groove texture: LEFT face (-X) ---
        translate([-total_w / 2, 0, total_h / 2])
        rotate([0, 0, -90])
            stone_grooves_xz(total_d, total_h,
                             groove_d, groove_w, groove_step);

        // --- Stone groove texture: RIGHT face (+X) ---
        translate([total_w / 2, 0, total_h / 2])
        rotate([0, 0, 90])
            stone_grooves_xz(total_d, total_h,
                             groove_d, groove_w, groove_step);
    }
}

// ============================================================
// SECTION A — BOTTOM: Cable Management Trunking  (Z 0 → cable_h)
// Features:
//   - Cable exit slots on front face (3x)
//   - Cable exit slot on back face (1x wide)
//   - Slot through base plate for vertical cable routing
//   - Internal cable trunking divider wall
//   - 4x M4 mounting bosses at corners
// ============================================================
module section_cable() {
    z0 = 0;

    // Internal divider — separates power cables from signal cables
    translate([0, 0, z0 + wall_t + (cable_h - wall_t) / 2])
        cube([
            total_w - 2 * wall_t,
            wall_t,
            cable_h - wall_t - 1
        ], center=true);

    // --- M4 mounting bosses at base (4 corners) ---
    for (sx = [-1, 1]) for (sy = [-1, 1]) {
        translate([
            sx * (total_w / 2 - m4_inset_x),
            sy * (total_d / 2 - m4_inset_y),
            z0
        ])
        m4_boss(m4_boss_h);
    }
}

// Cutouts that go INTO the shell for the cable section
module section_cable_cuts() {
    z0 = 0;
    slot_spacing = cable_slot_w + 8;

    // Front face cable exit slots
    for (i = [-(num_slots - 1) / 2 : (num_slots - 1) / 2]) {
        translate([
            i * slot_spacing,
            total_d / 2,
            z0 + wall_t + cable_slot_h / 2
        ])
        cube([cable_slot_w, wall_t + 2, cable_slot_h], center=true);
    }

    // Back face cable exit slot (wider — main cable bundle)
    translate([0, -total_d / 2, z0 + wall_t + cable_slot_h / 2])
        cube([cable_slot_w * 2, wall_t + 2, cable_slot_h], center=true);

    // Base plate through-slot for vertical cable routing
    translate([0, 0, -1])
        cube([cable_slot_w * 1.5, 12, wall_t + 2], center=true);

    // M4 clearance holes through base plate
    for (sx = [-1, 1]) for (sy = [-1, 1]) {
        translate([
            sx * (total_w / 2 - m4_inset_x),
            sy * (total_d / 2 - m4_inset_y),
            -1
        ])
        cylinder(d=m4_d, h=wall_t + m4_boss_h + 2);
    }
}

// ============================================================
// SECTION B — MIDDLE: Raspberry Pi 4 Housing  (Z cable_h → cable_h+rpi_h)
// Features:
//   - 4x RPi4 PCB standoffs (M2.5, 58x49 mm hole pattern)
//   - 2x 40 mm fan openings on front face (heatsink cooling)
//   - Hex ventilation grilles on left and right side walls
//   - Rear port cutouts (USB, HDMI, GPIO simplified openings)
// ============================================================
module section_rpi() {
    z0 = cable_h;

    // --- RPi4 PCB standoffs ---
    rpi_base_z = z0 + wall_t;
    for (sx = [-1, 1]) for (sy = [-1, 1]) {
        translate([sx * rpi_mnt_x, sy * rpi_mnt_y, rpi_base_z])
        difference() {
            cylinder(d=6, h=rpi_standoff);
            cylinder(d=2.8, h=rpi_standoff + 1);   // M2.5 tap hole
        }
    }
}

// Cutouts for RPi section
module section_rpi_cuts() {
    z0    = cable_h;
    fan_z = z0 + rpi_h / 2;           // Fans centred vertically in section
    fan_spacing = fan_size + fan_gap;

    // --- Two 40 mm fan openings on FRONT face ---
    for (side = [-1, 1]) {
        translate([side * fan_spacing / 2, total_d / 2, fan_z])
        rotate([90, 0, 0])
            fan_cutout(wall_t);
    }

    // --- Hex grille on LEFT side wall ---
    translate([-total_w / 2, 0, fan_z])
    rotate([0, 90, 0])
        hex_grid(hex_cols, hex_rows, hex_r, hex_gap, wall_t);

    // --- Hex grille on RIGHT side wall ---
    translate([total_w / 2, 0, fan_z])
    rotate([0, -90, 0])
        hex_grid(hex_cols, hex_rows, hex_r, hex_gap, wall_t);

    // --- Rear port cutouts (back face, -Y) ---
    // USB-A × 2 stack area
    translate([-22, -(total_d / 2), z0 + rpi_standoff + rpi_pcb_t + 10])
        cube([30, wall_t + 2, 18], center=true);

    // USB-C power + HDMI × 2 area
    translate([18, -(total_d / 2), z0 + rpi_standoff + rpi_pcb_t + 7])
        cube([36, wall_t + 2, 14], center=true);

    // Ethernet port area
    translate([-32, -(total_d / 2), z0 + rpi_standoff + rpi_pcb_t + 8])
        cube([18, wall_t + 2, 16], center=true);

    // GPIO ribbon cable slot (top of RPi section)
    translate([0, -(total_d / 2), z0 + rpi_h - wall_t - 6])
        cube([52, wall_t + 2, 10], center=true);
}

// ============================================================
// SECTION C — TOP: Camera Mount + Visor  (Z cable_h+rpi_h → total_h)
// Features:
//   - 12 mm circular lens hole on front face
//   - Camera PCB pocket (25 × 24 mm) behind front wall
//   - Ribbon cable routing slot below PCB pocket
//   - Protective angled visor / rain hood above lens
//   - Two snap-post camera bracket mount points
// ============================================================
module section_camera() {
    z0   = cable_h + rpi_h;
    lens_z = z0 + cam_z_offset;       // Absolute Z of lens hole centre

    // --- Camera PCB snap posts (inside front wall) ---
    for (sx = [-1, 1]) {
        translate([
            sx * (cam_pcb_w / 2 + 3),
            total_d / 2 - wall_t - cam_pocket - 1,
            lens_z
        ])
        difference() {
            cylinder(d=5, h=12, center=true);
            cylinder(d=2.8, h=13, center=true);   // M2.5 tap hole
        }
    }

    // --- Protective visor above lens ---
    visor_base_z = lens_z + cam_lens_d / 2 + 3;
    visor_w_act  = total_w - 2 * chamfer;

    translate([0, total_d / 2 - wall_t / 2, visor_base_z])
    rotate([-visor_angle, 0, 0])
    difference() {
        union() {
            // Main horizontal slab
            translate([0, visor_proj / 2, visor_t / 2])
                cube([visor_w_act, visor_proj, visor_t], center=true);
            // Left gusset
            translate([-(visor_w_act / 2 - visor_t / 2), visor_proj * 0.3, 0])
                linear_extrude(height=visor_t)
                    polygon([[0,0],[0, visor_proj * 0.6],[-visor_t * 1.5, 0]]);
            // Right gusset
            translate([(visor_w_act / 2 - visor_t / 2), visor_proj * 0.3, 0])
                linear_extrude(height=visor_t)
                    polygon([[0,0],[0, visor_proj * 0.6],[visor_t * 1.5, 0]]);
        }
        // Front leading edge chamfer (rain runoff groove)
        translate([0, visor_proj, visor_t])
        rotate([45, 0, 0])
            cube([visor_w_act + 2, 4, 4], center=true);
    }
}

// Cutouts for camera section
module section_camera_cuts() {
    z0     = cable_h + rpi_h;
    lens_z = z0 + cam_z_offset;

    // --- Lens hole ---
    translate([0, total_d / 2, lens_z])
    rotate([90, 0, 0])
        cylinder(d=cam_lens_d, h=wall_t + 2, center=true);

    // --- Camera PCB seating pocket ---
    translate([0, total_d / 2 - wall_t - cam_pocket / 2, lens_z])
        cube([cam_pcb_w + 1, cam_pocket, cam_pcb_d + 1], center=true);

    // --- Ribbon cable routing slot (below PCB pocket) ---
    translate([0, total_d / 2, lens_z - cam_pcb_d / 2 - 3])
    rotate([90, 0, 0])
        cube([8, 5, wall_t + 2], center=true);

    // --- Hex grille on LEFT side (camera section ventilation) ---
    hex_z = z0 + (cam_h + top_cap_h) / 2;
    translate([-total_w / 2, 0, hex_z])
    rotate([0, 90, 0])
        hex_grid(hex_cols, 2, hex_r, hex_gap, wall_t);

    // --- Hex grille on RIGHT side ---
    translate([total_w / 2, 0, hex_z])
    rotate([0, -90, 0])
        hex_grid(hex_cols, 2, hex_r, hex_gap, wall_t);
}

// ============================================================
// ============================================================
//                 PRINTABLE PART MODULES
// ============================================================
// ============================================================

// ============================================================
// PART 1: FRONT SHELL
// The front half (positive Y side) of the main enclosure body.
// Clip plane is the XZ plane (Y = 0).
// ============================================================
module front_shell() {
    color("SaddleBrown", 0.92)
    difference() {
        union() {
            // Shell body clipped to front half
            intersection() {
                outer_shell();
                translate([0, total_d / 4, total_h / 2])
                    cube([total_w + 2, total_d / 2 + 0.01, total_h + 2],
                         center=true);
            }
            // Interior features that belong to front half
            intersection() {
                union() {
                    section_cable();
                    section_rpi();
                    section_camera();
                }
                translate([0, total_d / 4, total_h / 2])
                    cube([total_w + 2, total_d / 2, total_h + 2],
                         center=true);
            }
        }
        // Apply all cutouts
        section_cable_cuts();
        section_rpi_cuts();
        section_camera_cuts();

        // Split seam groove (cosmetic, makes the split line clean)
        translate([0, 0.5, total_h / 2])
            cube([total_w + 2, 1, total_h + 2], center=true);
    }
}

// ============================================================
// PART 2: BACK SHELL
// The back half (negative Y side) of the main enclosure body.
// ============================================================
module back_shell() {
    color("Peru", 0.92)
    difference() {
        union() {
            intersection() {
                outer_shell();
                translate([0, -total_d / 4, total_h / 2])
                    cube([total_w + 2, total_d / 2 + 0.01, total_h + 2],
                         center=true);
            }
            intersection() {
                union() {
                    section_cable();
                    section_rpi();
                    // Back shell gets no camera features
                }
                translate([0, -total_d / 4, total_h / 2])
                    cube([total_w + 2, total_d / 2, total_h + 2],
                         center=true);
            }
        }
        section_cable_cuts();
        section_rpi_cuts();
        section_camera_cuts();

        // Alignment pin HOLES on back shell mating surface
        for (pz = [
            cable_h + 20,
            cable_h + rpi_h / 2,
            cable_h + rpi_h - 20
        ]) {
            translate([0, 0, pz])
            rotate([90, 0, 0])
                cylinder(d=3.2, h=total_d / 2 + 2);
            translate([total_w / 2 - 18, 0, pz])
            rotate([90, 0, 0])
                cylinder(d=3.2, h=total_d / 2 + 2);
            translate([-(total_w / 2 - 18), 0, pz])
            rotate([90, 0, 0])
                cylinder(d=3.2, h=total_d / 2 + 2);
        }
    }
}

// ============================================================
// PART 3: CAMERA BRACKET
// Separate printable bracket that cradles the Pi Camera V3 PCB
// and clips into the front shell pocket.
// Print flat (Z as shown).
// ============================================================
module camera_bracket() {
    color("DarkSlateGray", 0.95)
    difference() {
        union() {
            // Base retention plate
            cube([cam_pcb_w + 8, cam_pcb_d + 8, 3], center=true);

            // Side clamping wings
            for (sx = [-1, 1]) {
                translate([sx * (cam_pcb_w / 2 + 2.5), 0, 4.5])
                    cube([5, cam_pcb_d + 8, 6], center=true);
            }

            // Lens alignment collar (ring around lens hole)
            translate([0, 0, 5.5])
            difference() {
                cylinder(d=cam_lens_d + 8, h=4);
                cylinder(d=cam_lens_d + 0.2, h=5);
            }
        }

        // PCB seating recess (1.8 mm deep, slightly oversize)
        translate([0, 0, 3 - rpi_pcb_t / 2])
            cube([cam_pcb_w + 0.3, cam_pcb_d + 0.3, rpi_pcb_t + 0.5],
                 center=true);

        // Lens through-hole
        cylinder(d=cam_lens_d, h=12, center=true);

        // M2 mounting holes (for attachment to snap posts)
        for (sx = [-1, 1]) {
            translate([sx * (cam_pcb_w / 2 + 3), 0, 0])
                cylinder(d=2.2, h=10, center=true, $fn=16);
        }

        // Ribbon cable exit slot at bottom
        translate([0, -(cam_pcb_d / 2 + 2), 0])
            cube([9, 6, 8], center=true);
    }
}

// ============================================================
// PART 4: CABLE COVER
// Snap-on decorative cover for the bottom cable management
// section. Slides over the base of the enclosure.
// Matches the same stone groove aesthetic.
// ============================================================
module cable_cover() {
    color("Sienna", 0.92)
    difference() {
        union() {
            // Outer shell (slightly undersize for fitment clearance)
            translate([0, 0, cable_h / 2])
                chamfered_box(
                    total_w - 0.6,
                    total_d - 0.6,
                    cable_h,
                    chamfer - 0.5
                );

            // Snap-fit retention tabs (4 sides, near top edge)
            for (rot = [0, 90, 180, 270]) {
                rotate([0, 0, rot])
                translate([total_w / 2 - wall_t - 0.8, 0,
                           cable_h - 10])
                    cube([wall_t, 10, 6], center=true);
            }
        }

        // Hollow interior
        translate([0, 0, wall_t + (cable_h - wall_t) / 2 + wall_t / 2])
            cube([
                total_w - 2 * wall_t - 0.6,
                total_d - 2 * wall_t - 0.6,
                cable_h
            ], center=true);

        // Match cable exit slots — front face
        slot_sp = cable_slot_w + 8;
        for (i = [-(num_slots - 1) / 2 : (num_slots - 1) / 2]) {
            translate([
                i * slot_sp,
                (total_d - 0.6) / 2,
                wall_t + cable_slot_h / 2
            ])
            cube([cable_slot_w, wall_t + 2, cable_slot_h], center=true);
        }

        // Match cable exit slot — back face
        translate([0, -(total_d - 0.6) / 2, wall_t + cable_slot_h / 2])
            cube([cable_slot_w * 2, wall_t + 2, cable_slot_h], center=true);

        // M4 clearance holes at base corners
        for (sx = [-1, 1]) for (sy = [-1, 1]) {
            translate([
                sx * (total_w / 2 - m4_inset_x),
                sy * (total_d / 2 - m4_inset_y),
                -1
            ])
            cylinder(d=m4_d + 1, h=m4_boss_h + wall_t + 2);
        }

        // Stone groove texture on cable cover faces
        // Front
        translate([0, (total_d - 0.6) / 2, cable_h / 2])
            stone_grooves_xz(total_w, cable_h,
                             groove_d, groove_w, groove_step);
        // Back
        translate([0, -(total_d - 0.6) / 2, cable_h / 2])
        rotate([0, 0, 180])
            stone_grooves_xz(total_w, cable_h,
                             groove_d, groove_w, groove_step);
        // Left
        translate([-(total_w - 0.6) / 2, 0, cable_h / 2])
        rotate([0, 0, -90])
            stone_grooves_xz(total_d, cable_h,
                             groove_d, groove_w, groove_step);
        // Right
        translate([(total_w - 0.6) / 2, 0, cable_h / 2])
        rotate([0, 0, 90])
            stone_grooves_xz(total_d, cable_h,
                             groove_d, groove_w, groove_step);
    }
}

// ============================================================
// ============================================================
//                   RENDER DISPATCHER
// ============================================================
// ============================================================

// Print useful dimension summary to the OpenSCAD console
echo("======================================");
echo("DEFENDER Stone Pillar Enclosure — FYP");
echo("======================================");
echo(str("Outer dims : ", total_w, " W x ", total_d, " D x ", total_h, " H mm"));
echo(str("Wall       : ", wall_t, " mm  |  Chamfer: ", chamfer, " mm"));
echo(str("Sections   : Cable 0-", cable_h,
         "  RPi ", cable_h, "-", cable_h + rpi_h,
         "  Camera ", cable_h + rpi_h, "-", total_h));
echo(str("Current PART = ", PART,
         "  (0=Assembly, 1=Front, 2=Back, 3=CamBracket, 4=CableCover)"));

if (PART == 0) {
    // Assembly overview — parts spread out for visual inspection
    translate([0, 0, 0])
    difference() {
        union() {
            outer_shell();
            section_cable();
            section_rpi();
            section_camera();
        }
        section_cable_cuts();
        section_rpi_cuts();
        section_camera_cuts();
    }
    // Camera bracket shown to the right
    translate([total_w + 20, 0, 10])
        camera_bracket();
    // Cable cover shown to the left
    translate([-(total_w + 20), 0, 0])
        cable_cover();

} else if (PART == 1) {
    front_shell();

} else if (PART == 2) {
    back_shell();

} else if (PART == 3) {
    // Camera bracket oriented flat on print bed
    camera_bracket();

} else if (PART == 4) {
    cable_cover();
}

// ============================================================
// END OF FILE — defender_pillar_enclosure.scad
// ============================================================
//
// SLICING / PRINT NOTES:
// -------------------------------------------------------
// Front Shell  : Print upright. Supports needed under visor
//                overhang and fan cutout overhangs.
//                Recommended: PETG or ASA, 3 perimeters,
//                25% gyroid infill, 0.2 mm layer height.
//
// Back Shell   : Print upright. Minimal supports needed.
//                Same material / settings as front shell.
//
// Camera Bracket: Print flat (as drawn). No supports needed.
//                 PLA or PETG, 4 perimeters, 40% infill.
//
// Cable Cover  : Print upright (open end up).
//                Same settings as main shells.
//
// ASSEMBLY ORDER:
//   1. Mount RPi4 onto standoffs inside back shell (M2.5 screws).
//   2. Feed all cables through cable trunking section.
//   3. Attach Pi Camera V3 to camera bracket; seat into pocket.
//   4. Join front shell to back shell (alignment pins + M3 screws
//      through side wall threaded inserts).
//   5. Snap cable cover onto base.
//   6. Mount assembly to pole/wall with 4x M4 bolts through base.
//
// MATERIAL SUGGESTION:
//   PETG (UV resistant) or ASA for outdoor deployments.
//   Spray paint with grey stone-effect aerosol + brown wash
//   for authentic stone pillar appearance.
// ============================================================
