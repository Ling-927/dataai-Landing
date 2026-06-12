// ============================================================
// Defender Stone Pillar Enclosure
// Final Year Project - Raspberry Pi 4 + Pi Camera V3
// ============================================================
// A stone pillar aesthetic enclosure with camera mount,
// RPi housing, fan openings, hex vents, and cable management.
// ============================================================

// --- RENDER CONTROL ---
// Set PART to one of:
//   "assembly"       - full assembly preview
//   "front_shell"    - front half shell
//   "back_shell"     - back half shell
//   "camera_bracket" - camera mount bracket
//   "cable_cover"    - bottom cable management cover
PART = "assembly";

// ============================================================
// GLOBAL PARAMETERS
// ============================================================

// Overall enclosure dimensions
total_width  = 120;   // mm, X axis
total_depth  = 80;    // mm, Y axis
total_height = 300;   // mm, Z axis

// Wall thickness
wall = 3;             // mm

// Chamfer size on vertical edges
chamfer = 6;          // mm

// Stone groove parameters
groove_depth  = 1.0;  // mm deep into wall
groove_width  = 1.5;  // mm wide
groove_spacing = 20;  // mm between grooves

// --- Section heights ---
base_height   = 40;   // cable management section
mid_height    = 180;  // RPi + fan section
top_height    = 80;   // camera section
// total_height = base_height + mid_height + top_height = 300

// --- Camera parameters ---
camera_lens_dia    = 12;   // mm lens hole diameter
camera_pcb_w       = 25;   // mm camera PCB width
camera_pcb_h       = 24;   // mm camera PCB height
camera_pcb_thick   = 10;   // mm standoff + PCB depth
hood_depth         = 18;   // mm how far the visor protrudes
hood_height        = 10;   // mm thickness of visor
hood_width         = 50;   // mm width of visor

// --- RPi compartment parameters ---
rpi_pcb_w    = 85;    // mm RPi 4 PCB width
rpi_pcb_d    = 56;    // mm RPi 4 PCB depth
rpi_clearance = 20;   // mm height clearance above PCB
rpi_floor    = wall + 2; // mm floor above base section

// --- Fan parameters ---
fan_size     = 40;    // mm fan opening (square)
fan_corner_r = 4;     // mm rounded corners on fan opening
fan_count    = 2;     // two fans side by side
fan_gap      = 4;     // mm gap between fans

// --- Hex vent parameters ---
hex_r        = 4;     // mm hex cell circumradius
hex_margin   = wall + 2; // mm border margin for hex grid

// --- Cable management ---
cable_hole_dia  = 12; // mm cable exit hole diameter
cable_hole_count = 3; // number of exit holes at base

// --- Base mounting ---
mount_screw_dia = 4.5; // mm M4 screw hole (clearance)
mount_boss_dia  = 10;  // mm boss outer diameter
mount_inset     = 12;  // mm inset from corner

// --- Split: front/back shell divide at Y midplane ---
split_y = total_depth / 2; // 40mm

// ============================================================
// UTILITY MODULES
// ============================================================

// Rounded rectangle in 2D (for extrusion)
module rounded_rect_2d(w, d, r) {
    offset(r = r) offset(r = -r)
        square([w, d], center = true);
}

// Chamfered rectangular prism (vertical chamfers on 4 corners)
// Chamfer is a 45-degree cut along the full Z height
module chamfered_box(w, d, h, ch) {
    // Create octagonal cross-section by subtracting corner prisms
    difference() {
        cube([w, d, h], center = false);
        // Cut each vertical corner
        translate([0, 0, -1])
            rotate([0, 0, 45])
                cube([ch * 1.415, ch * 1.415, h + 2], center = true);
        translate([w, 0, -1])
            rotate([0, 0, 45])
                cube([ch * 1.415, ch * 1.415, h + 2], center = true);
        translate([0, d, -1])
            rotate([0, 0, 45])
                cube([ch * 1.415, ch * 1.415, h + 2], center = true);
        translate([w, d, -1])
            rotate([0, 0, 45])
                cube([ch * 1.415, ch * 1.415, h + 2], center = true);
    }
}

// Chamfered box centered at origin in X and Y, base at Z=0
module chamfered_box_centered(w, d, h, ch) {
    translate([-w/2, -d/2, 0])
        chamfered_box(w, d, h, ch);
}

// Single hexagon in 2D (flat-top orientation)
module hexagon_2d(r) {
    polygon(points = [
        [ r,       0       ],
        [ r/2,     r*0.866 ],
        [-r/2,     r*0.866 ],
        [-r,       0       ],
        [-r/2,    -r*0.866 ],
        [ r/2,    -r*0.866 ]
    ]);
}

// ============================================================
// MODULE: stone_groove_texture
// Cuts horizontal groove lines into a flat face.
// face_w = width, face_h = height of the face area
// Grooves are cut as thin slots going into the wall.
// Apply as difference() subtraction on a shell face.
// ox, oy = offset of groove area origin
// depth = how deep into the part (local -Y for front face)
// ============================================================
module stone_groove_texture(face_w, face_h, oz, cut_depth) {
    num_grooves = floor(face_h / groove_spacing);
    for (i = [1 : num_grooves - 1]) {
        gz = oz + i * groove_spacing;
        translate([-face_w/2 - 1, -cut_depth - 1, gz - groove_width/2])
            cube([face_w + 2, cut_depth + 2, groove_width]);
    }
}

// ============================================================
// MODULE: hex_grid
// Fills an area with hexagonal holes.
// w, h = bounding box of grid area
// Centered at origin in XZ, caller translates.
// ============================================================
module hex_grid(area_w, area_h, hr, thk) {
    col_spacing = hr * 1.732;  // sqrt(3)*r  - flat-top hex
    row_spacing = hr * 1.5;
    cols = floor((area_w - 2 * hex_margin) / col_spacing);
    rows = floor((area_h - 2 * hex_margin) / row_spacing);
    start_x = -(cols - 1) * col_spacing / 2;
    start_z = -(rows - 1) * row_spacing / 2;
    for (row = [0 : rows - 1]) {
        offset_x = (row % 2 == 0) ? 0 : col_spacing / 2;
        for (col = [0 : cols - 1]) {
            cx = start_x + col * col_spacing + offset_x;
            cz = start_z + row * row_spacing;
            translate([cx, 0, cz])
                rotate([90, 0, 0])
                    linear_extrude(thk + 2)
                        hexagon_2d(hr * 0.82);
        }
    }
}

// ============================================================
// MODULE: fan_opening
// Two 40mm fan openings side by side on the front face.
// Centered at origin, caller translates.
// ============================================================
module fan_opening(thk) {
    total_fans_w = fan_count * fan_size + (fan_count - 1) * fan_gap;
    for (i = [0 : fan_count - 1]) {
        cx = (i - (fan_count - 1) / 2) * (fan_size + fan_gap);
        translate([cx, 0, 0])
            rotate([90, 0, 0])
                linear_extrude(thk + 2)
                    offset(r = fan_corner_r) offset(r = -fan_corner_r)
                        square([fan_size - 2, fan_size - 2], center = true);
    }
}

// ============================================================
// MODULE: rpi_compartment
// Interior cavity for RPi 4 PCB. Carved out of mid section.
// Centered at X=0, bottom at Z = base_height + rpi_floor.
// ============================================================
module rpi_compartment() {
    rz = base_height + rpi_floor;
    cavity_h = rpi_clearance + 5; // PCB + clearance
    // Main RPi cavity
    translate([0, 0, rz])
        cube([rpi_pcb_w + 4, rpi_pcb_d + 4, cavity_h + 10], center = false);
}

// ============================================================
// MODULE: camera_section
// Top section with lens hole and Pi Camera mount features.
// Base at Z = base_height + mid_height
// ============================================================
module camera_section_cutouts() {
    cam_base_z = base_height + mid_height;
    cam_center_z = cam_base_z + top_height / 2 + 5;
    // Lens hole through front wall
    translate([0, -total_depth/2 - 1, cam_center_z])
        rotate([-90, 0, 0])
            cylinder(d = camera_lens_dia, h = wall + 10, $fn = 40);
    // Camera PCB recess pocket (inside)
    translate([-camera_pcb_w/2, -total_depth/2 + wall, cam_center_z - camera_pcb_h/2])
        cube([camera_pcb_w, camera_pcb_thick, camera_pcb_h]);
}

// ============================================================
// MODULE: camera_bracket
// Separate printed part: a bracket to hold Pi Camera V3.
// Mounts inside top section.
// ============================================================
module camera_bracket() {
    br_w = camera_pcb_w + 6;
    br_h = camera_pcb_h + 6;
    br_d = camera_pcb_thick + 4;
    difference() {
        union() {
            // Main bracket body
            translate([-br_w/2, 0, -br_h/2])
                cube([br_w, br_d, br_h]);
            // Mounting tabs
            translate([-br_w/2 - 8, 0, -4])
                cube([8, br_d - 2, 8]);
            translate([br_w/2, 0, -4])
                cube([8, br_d - 2, 8]);
        }
        // Lens hole
        translate([0, -1, 0])
            rotate([-90, 0, 0])
                cylinder(d = camera_lens_dia, h = br_d + 2, $fn = 40);
        // PCB pocket
        translate([-camera_pcb_w/2, wall, -camera_pcb_h/2])
            cube([camera_pcb_w, camera_pcb_thick - 1, camera_pcb_h]);
        // M2 camera PCB screw holes (21mm spacing)
        for (mx = [-10.5, 10.5]) {
            for (mz = [-7.5, 7.5]) {
                translate([mx, -1, mz])
                    rotate([-90, 0, 0])
                        cylinder(d = 2.2, h = br_d + 2, $fn = 20);
            }
        }
    }
}

// ============================================================
// MODULE: base_mount_holes
// M4 mounting screw holes at the four corners of the base.
// ============================================================
module base_mount_holes() {
    positions = [
        [ total_width/2 - mount_inset,  total_depth/2 - mount_inset ],
        [-total_width/2 + mount_inset,  total_depth/2 - mount_inset ],
        [ total_width/2 - mount_inset, -total_depth/2 + mount_inset ],
        [-total_width/2 + mount_inset, -total_depth/2 + mount_inset ]
    ];
    for (p = positions) {
        translate([p[0], p[1], -1])
            cylinder(d = mount_screw_dia, h = wall + 2, $fn = 20);
    }
}

// ============================================================
// MODULE: cable_cover
// Separate printable bottom cover with cable exit holes.
// Snaps onto / bolts to base of front/back shells.
// ============================================================
module cable_cover() {
    cover_h = base_height - wall;
    difference() {
        union() {
            // Outer shell of cable cover
            difference() {
                chamfered_box_centered(total_width, total_depth, cover_h, chamfer);
                // Hollow interior
                translate([0, 0, wall])
                    cube([total_width - wall*2, total_depth - wall*2, cover_h], center = true);
            }
            // Internal cable guides/ribs
            for (rx = [-20, 0, 20]) {
                translate([rx - 1, -total_depth/2 + wall, wall])
                    cube([2, total_depth - wall*2, cover_h - wall*2]);
            }
        }
        // Cable exit holes at bottom face
        spacing = (total_width - 40) / (cable_hole_count - 1);
        for (i = [0 : cable_hole_count - 1]) {
            cx = -( (total_width - 40) / 2 ) + i * spacing;
            translate([cx, 0, -1])
                cylinder(d = cable_hole_dia, h = wall + 2, $fn = 24);
        }
        // Stone groove texture on cable cover front face
        translate([0, -total_depth/2, 0])
            stone_groove_texture(total_width - chamfer*2, cover_h, 0, groove_depth);
        // Stone groove texture on cable cover back face
        translate([0, total_depth/2, 0])
            mirror([0, 1, 0])
                stone_groove_texture(total_width - chamfer*2, cover_h, 0, groove_depth);
    }
}

// ============================================================
// MODULE: front_shell
// Front half of the main enclosure body (Y < 0 half).
// Contains: camera lens cutout, fan openings, hex side vents,
//           stone groove texture, RPi cavity cutout.
// ============================================================
module front_shell() {
    difference() {
        union() {
            // Main body (front half)
            difference() {
                chamfered_box_centered(total_width, total_depth, total_height, chamfer);
                // Hollow interior
                translate([0, 0, wall])
                    cube([total_width - wall*2, total_depth - wall*2, total_height], center = true);
                // Cut at split plane — keep only Y <= 0 (front half)
                translate([-total_width/2 - 1, 0, -1])
                    cube([total_width + 2, total_depth/2 + 1, total_height + 2]);
            }
        }
        // --- Camera lens hole (top section front face) ---
        cam_center_z = base_height + mid_height + top_height/2 + 5;
        translate([0, -total_depth/2 - 1, cam_center_z])
            rotate([-90, 0, 0])
                cylinder(d = camera_lens_dia, h = wall + 5, $fn = 40);

        // --- Fan openings (mid section front face, lower half of mid) ---
        fan_center_z = base_height + 50;
        translate([0, -total_depth/2 - 1, fan_center_z])
            fan_opening(wall + 2);

        // --- Hex vent grilles on left side wall ---
        hex_center_z = base_height + mid_height/2;
        translate([-total_width/2, 0, hex_center_z])
            rotate([0, 90, 0])
                hex_grid(mid_height - 20, total_depth - 20, hex_r, wall + 2);

        // --- Stone grooves on front face ---
        translate([0, -total_depth/2, 0])
            stone_groove_texture(total_width - chamfer*2, total_height, 0, groove_depth);

        // --- Stone grooves on left side ---
        translate([-total_width/2, 0, 0])
            rotate([0, 0, 90])
                stone_groove_texture(total_depth - chamfer*2, total_height, 0, groove_depth);

        // --- Base mount holes ---
        base_mount_holes();

        // --- RPi compartment alignment pins (recesses) ---
        rz = base_height + rpi_floor;
        // Snap fit notches on split face
        for (nz = [rz + 10, rz + 40, rz + 80]) {
            translate([-total_width/4, 0, nz])
                rotate([90, 0, 0])
                    cylinder(d = 3, h = 6, $fn = 16, center = true);
        }

        // --- M3 shell-joining screw holes on split face ---
        for (jz = [20, 80, 150, 230, 280]) {
            translate([0, 0, jz])
                rotate([90, 0, 0])
                    cylinder(d = 3.4, h = total_depth + 2, $fn = 16, center = true);
        }

        // --- Camera bracket pocket at top ---
        translate([-camera_pcb_w/2 - 3, -total_depth/2 + wall, cam_center_z - camera_pcb_h/2 - 3])
            cube([camera_pcb_w + 6, camera_pcb_thick + 3, camera_pcb_h + 6]);
    }
}

// ============================================================
// MODULE: back_shell
// Back half of the main enclosure body (Y > 0 half).
// Contains: hex side vents (right side), stone grooves,
//           RPi IO port cutout area, alignment bosses.
// ============================================================
module back_shell() {
    difference() {
        union() {
            // Main body (back half)
            difference() {
                chamfered_box_centered(total_width, total_depth, total_height, chamfer);
                // Hollow interior
                translate([0, 0, wall])
                    cube([total_width - wall*2, total_depth - wall*2, total_height], center = true);
                // Cut at split plane — keep only Y >= 0 (back half)
                translate([-total_width/2 - 1, -total_depth/2 - 1, -1])
                    cube([total_width + 2, total_depth/2 + 1, total_height + 2]);
            }
            // Alignment bosses on split face
            for (jz = [20, 80, 150, 230, 280]) {
                translate([0, 0, jz])
                    rotate([90, 0, 0])
                        difference() {
                            cylinder(d = mount_boss_dia, h = 4, $fn = 20, center = true);
                            cylinder(d = 3.4, h = 6, $fn = 16, center = true);
                        }
            }
        }
        // --- Hex vent grilles on right side wall ---
        hex_center_z = base_height + mid_height/2;
        translate([total_width/2, 0, hex_center_z])
            rotate([0, -90, 0])
                hex_grid(mid_height - 20, total_depth - 20, hex_r, wall + 2);

        // --- Hex vent grilles on back face ---
        translate([0, total_depth/2, hex_center_z])
            rotate([90, 0, 0])
                hex_grid(total_width - 20, mid_height - 20, hex_r, wall + 2);

        // --- Stone grooves on back face ---
        translate([0, total_depth/2, 0])
            mirror([0, 1, 0])
                stone_groove_texture(total_width - chamfer*2, total_height, 0, groove_depth);

        // --- Stone grooves on right side ---
        translate([total_width/2, 0, 0])
            rotate([0, 0, -90])
                stone_groove_texture(total_depth - chamfer*2, total_height, 0, groove_depth);

        // --- Base mount holes ---
        base_mount_holes();

        // --- RPi USB/Ethernet port cutout on back face ---
        rz = base_height + rpi_floor;
        translate([0, total_depth/2 - 1, rz + 5])
            cube([75, wall + 5, 20], center = false);

        // --- M3 shell-joining screw holes ---
        for (jz = [20, 80, 150, 230, 280]) {
            translate([0, 0, jz])
                rotate([90, 0, 0])
                    cylinder(d = 3.4, h = total_depth + 2, $fn = 16, center = true);
        }
    }
}

// ============================================================
// MODULE: assembly
// Preview all parts in their assembled positions.
// ============================================================
module assembly() {
    color("SaddleBrown", 0.9)   front_shell();
    color("Peru",        0.9)   back_shell();
    color("Sienna",      0.85)  cable_cover();
    // Camera bracket shown in position
    cam_center_z = base_height + mid_height + top_height/2 + 5;
    color("DimGray", 0.95)
        translate([0, -total_depth/2 + wall + camera_pcb_thick/2 + 1, cam_center_z])
            rotate([90, 0, 0])
                camera_bracket();
}

// ============================================================
// RENDER CONTROL
// ============================================================
if (PART == "assembly") {
    assembly();
} else if (PART == "front_shell") {
    // Orient for printing: split face down
    rotate([90, 0, 0])
        front_shell();
} else if (PART == "back_shell") {
    // Orient for printing: split face down
    rotate([-90, 0, 0])
        back_shell();
} else if (PART == "camera_bracket") {
    camera_bracket();
} else if (PART == "cable_cover") {
    cable_cover();
} else {
    // Default: show assembly
    assembly();
}
