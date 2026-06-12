// ============================================================
// DEFENDER — Gate Pillar System (Tiang Pagar Moden)
// Inspired by: modern concrete gate pillars
// Tiang 1 (Kiri) : Pi Camera V3 + Panel (Intercom-style)
// Tiang 2 (Kanan): Clean pillar (mirror)
// Underground Box: RPi4 + Dual Fan
// ============================================================
// Pi Camera V3: PCB 25x24mm, lens 7.4mm dia
// RPi4: PCB 85x56mm, standoff hole pattern 58x49mm
// ============================================================
$fn = 64;

// ============================================================
// PART SELECTOR
// 0 = Full scene (both pillars + underground box + ground)
// 1 = Tiang Kiri  (Camera + Panel pillar)
// 2 = Tiang Kanan (Clean pillar)
// 3 = Underground Box
// 4 = Underground Box Lid
// 5 = Intercom Panel only
// ============================================================
PART = 0;

// ============================================================
// PILLAR DIMENSIONS  (concrete modern gate pillar)
// ============================================================
p_w       = 120;    // Pillar body width  (X)
p_d       = 120;    // Pillar body depth  (Y)
p_h       = 350;    // Pillar body height (Z)  — excludes cap
wall_t    = 5;      // Wall thickness

// Cap (wider flat slab on top)
cap_w     = 138;    // Cap width
cap_d     = 138;    // Cap depth
cap_h     = 28;     // Cap height

// Horizontal groove lines (simulate concrete block joints)
groove_step = 30;   // Spacing between grooves
groove_d    = 1.2;  // Groove depth
groove_w    = 2.0;  // Groove width

// ============================================================
// INTERCOM PANEL DIMENSIONS (left pillar front face)
// ============================================================
panel_w   = 80;     // Panel width
panel_h   = 160;    // Panel height
panel_t   = 12;     // Panel protrusion from face
panel_z   = 160;    // Panel base height from ground
panel_r   = 4;      // Panel corner radius

// ============================================================
// PI CAMERA V3 — ACTUAL MEASUREMENTS
// ============================================================
cam_pcb_w  = 25;
cam_pcb_d  = 24;
cam_lens_d = 7.4;
cam_fpc_w  = 16;
cam_fpc_t  = 2;
// Camera position inside panel (from panel bottom)
cam_z_in_panel = 148;   // maksimum atas panel — tinggi untuk sudut turun lebih tajam
cam_tilt   = 35;         // downward tilt untuk tangkap no. plate kenderaan (optimal 30-40deg)

// ============================================================
// BUZZER — 12mm passive buzzer (actual)
// ============================================================
buzz_d     = 12.5;
buzz_z_in_panel = 60;    // height inside panel

// ============================================================
// LED — 5mm LED
// ============================================================
led_d      = 5.2;
led_z_in_panel = 85;     // height inside panel

// ============================================================
// UNDERGROUND BOX — RPi4 + Dual Fan
// ============================================================
box_w     = 180;
box_d     = 120;
box_h     = 90;
box_wall  = 5;
box_lid_h = 8;
rpi_mnt_x = 58 / 2;
rpi_mnt_y = 49 / 2;
fan_r     = 17;
fan_screw = 3.2;

// Scene spacing
pillar_sep = 200;   // centre-to-centre distance
box_z      = -box_h - 20;  // underground box Z (below ground)

// ============================================================
// UTILITIES
// ============================================================

module groove_lines(face_w, face_h, dep, gw, step) {
    num = floor(face_h / step);
    for (i = [1:num]) {
        translate([0, -dep/2, i*step - face_h/2])
            cube([face_w + 2, dep, gw], center=true);
    }
}

module rounded_box(w, d, h, r) {
    // Box with rounded vertical edges only
    hull() {
        for (sx=[-1,1]) for (sy=[-1,1])
            translate([sx*(w/2-r), sy*(d/2-r), 0])
                cylinder(r=r, h=h, $fn=32);
    }
}

module hex_prism(r, h) { cylinder(r=r, h=h, $fn=6); }
module hex_grid(cols, rows, r, gap, depth) {
    sx = r*2+gap; sy = r*sqrt(3)+gap;
    for (row=[0:rows-1]) for (col=[0:cols-1]) {
        ox = (row%2==1) ? sx/2 : 0;
        translate([col*sx+ox-(cols-1)*sx/2, row*sy-(rows-1)*sy/2, 0])
            hex_prism(r, depth+1);
    }
}

module fan_hole(wt) {
    cylinder(r=fan_r, h=wt+2, center=true);
    co = 40/2 - 4;
    for (sx=[-1,1]) for (sy=[-1,1])
        translate([sx*co, sy*co, 0])
            cylinder(d=fan_screw, h=wt+2, center=true, $fn=16);
}

// ============================================================
// PILLAR BODY — hollow concrete block style
// ============================================================
module pillar_body(w, d, h) {
    difference() {
        // Outer solid
        translate([0,0,h/2])
            cube([w, d, h], center=true);

        // Hollow interior
        translate([0,0,wall_t + h/2])
            cube([w-2*wall_t, d-2*wall_t, h], center=true);

        // Horizontal groove lines — all 4 faces
        // Front (+Y)
        translate([0, d/2, h/2])
            groove_lines(w, h, groove_d, groove_w, groove_step);
        // Back (-Y)
        translate([0, -d/2, h/2])
        rotate([0,0,180])
            groove_lines(w, h, groove_d, groove_w, groove_step);
        // Left (-X)
        translate([-w/2, 0, h/2])
        rotate([0,0,-90])
            groove_lines(d, h, groove_d, groove_w, groove_step);
        // Right (+X)
        translate([w/2, 0, h/2])
        rotate([0,0,90])
            groove_lines(d, h, groove_d, groove_w, groove_step);
    }
}

// Flat cap on top of pillar (overhangs on all sides)
module pillar_cap(w, d, h) {
    // Lower chamfer lip
    hull() {
        translate([0,0,0]) cube([w+4, d+4, 2], center=true);
        translate([0,0,h]) cube([w, d, 2], center=true);
    }
}

// ============================================================
// INTERCOM PANEL — mounts flush on pillar front face
// Contains: Camera V3 (top), LED (mid), Buzzer (low)
// ============================================================
module intercom_panel() {
    color("#3A4A55", 1.0)
    difference() {
        union() {
            // Panel body with rounded corners
            translate([0, 0, panel_h/2])
                rounded_box(panel_w, panel_t, panel_h, panel_r);

            // Camera housing bump (protruding lens housing)
            translate([0, panel_t/2, cam_z_in_panel])
            rotate([-cam_tilt, 0, 0])
                cylinder(d=cam_lens_d+12, h=8, $fn=32);
        }

        // --- Camera lens hole (tilted downward) ---
        translate([0, panel_t/2, cam_z_in_panel])
        rotate([-cam_tilt, 0, 0])
        rotate([90,0,0])
            cylinder(d=cam_lens_d, h=panel_t+10, center=true);

        // Camera PCB pocket (behind front face)
        translate([0, panel_t/2 - wall_t - 1, cam_z_in_panel])
            cube([cam_pcb_w+1, 5, cam_pcb_d+1], center=true);

        // FPC ribbon slot below camera
        translate([0, panel_t/2 - 1, cam_z_in_panel - cam_pcb_d/2 - 4])
        rotate([90,0,0])
            cube([cam_fpc_w, cam_fpc_t, panel_t+2], center=true);

        // --- LED hole ---
        translate([0, 0, led_z_in_panel])
        rotate([90,0,0])
            cylinder(d=led_d, h=panel_t+2, center=true);

        // --- Buzzer hole ---
        translate([0, 0, buzz_z_in_panel])
        rotate([90,0,0])
            cylinder(d=buzz_d, h=panel_t+2, center=true);

        // Buzzer pin holes
        for (px=[-3.5, 3.5])
            translate([px, 0, buzz_z_in_panel - buzz_d/2 - 4])
            rotate([90,0,0])
                cylinder(d=1.2, h=panel_t+2, center=true, $fn=16);

        // Panel mounting screw holes (4 corners)
        for (sx=[-1,1]) for (sz=[-1,1])
            translate([sx*(panel_w/2-8), 0, panel_h/2 + sz*(panel_h/2-10)])
            rotate([90,0,0])
                cylinder(d=3.2, h=panel_t+2, center=true, $fn=16);

        // Cable channel (bottom of panel)
        translate([0, 0, 8])
        rotate([90,0,0])
            cube([18, 14, panel_t+2], center=true);

        // Side vent slots (right edge)
        for (sz=[30, 50, 70])
            translate([panel_w/2, 0, sz])
            rotate([90,0,90])
                cube([3, 12, panel_t+2], center=true);
    }
}

// ============================================================
// TIANG KIRI — Camera + Intercom Panel
// ============================================================
module tiang_kiri() {
    color("#8A9BA8", 1.0)
    union() {
        difference() {
            union() {
                // Pillar body
                pillar_body(p_w, p_d, p_h);

                // Cap
                translate([0, 0, p_h])
                    pillar_cap(cap_w, cap_d, cap_h);

                // Base plate (footing)
                translate([0, 0, -8])
                    cube([cap_w, cap_d, 8], center=true);

                // Panel mounting boss (flush recess on front face)
                translate([0, p_d/2, panel_z + panel_h/2])
                    cube([panel_w + 2*wall_t, wall_t, panel_h + 2*wall_t],
                         center=true);
            }

            // Panel recess cutout on front face (so panel sits flush)
            translate([0, p_d/2 + panel_t/2 - 0.5, panel_z + panel_h/2])
                rounded_box(panel_w + 0.5, panel_t + 1, panel_h + 0.5, panel_r);

            // Cable hole through pillar (FPC to underground)
            translate([0, 0, 30])
                cylinder(d=22, h=60, center=true);

            // Base cable exit
            translate([0, -p_d/2, 25])
            rotate([90,0,0])
                cylinder(d=18, h=wall_t+2, center=true);
        }

        // Intercom panel mounted on front face
        translate([0, p_d/2, panel_z])
            intercom_panel();
    }
}

// ============================================================
// TIANG KANAN — Clean Pillar (no panel)
// ============================================================
module tiang_kanan() {
    color("#8A9BA8", 1.0)
    difference() {
        union() {
            pillar_body(p_w, p_d, p_h);
            translate([0, 0, p_h])
                pillar_cap(cap_w, cap_d, cap_h);
            translate([0, 0, -8])
                cube([cap_w, cap_d, 8], center=true);
        }
        // Cable hole (for future wiring)
        translate([0, 0, 30])
            cylinder(d=22, h=60, center=true);
    }
}

// ============================================================
// UNDERGROUND BOX — RPi4 + Dual 40mm Fan
// ============================================================
module underground_box() {
    color("#4A5560", 1.0)
    difference() {
        union() {
            translate([0,0,box_h/2])
                cube([box_w, box_d, box_h], center=true);

            // RPi4 standoffs (actual 58x49mm mounting hole pattern)
            rpi_ox = -25;
            for (sx=[-1,1]) for (sy=[-1,1])
                translate([rpi_ox+sx*rpi_mnt_x, sy*rpi_mnt_y, box_wall])
                difference() {
                    cylinder(d=7, h=6);
                    cylinder(d=2.8, h=7);
                }

            // Lid alignment ridge
            translate([0,0,box_h-box_wall-2])
            difference() {
                cube([box_w-2*box_wall-0.4, box_d-2*box_wall-0.4, box_wall+2], center=true);
                cube([box_w-2*box_wall-5, box_d-2*box_wall-5, box_wall+5], center=true);
            }
        }

        // Hollow
        translate([0,0,box_wall+(box_h-box_wall)/2])
            cube([box_w-2*box_wall, box_d-2*box_wall, box_h], center=true);

        // Dual fan exhaust — right wall
        fan_z = box_wall + 25;
        for (fy=[-1,1])
            translate([box_w/2, fy*22, fan_z])
            rotate([0,90,0])
                fan_hole(box_wall);

        // Hex intake — left wall
        translate([-box_w/2, 0, fan_z])
        rotate([0,-90,0])
            hex_grid(4, 3, 5, 2, box_wall);

        // Cable entries top (2 pillars)
        translate([-pillar_sep/2, 0, box_h-box_wall/2])
            cylinder(d=24, h=box_wall+2, center=true);
        translate([pillar_sep/2, 0, box_h-box_wall/2])
            cylinder(d=24, h=box_wall+2, center=true);

        // Power cable entry back wall
        translate([0, -box_d/2, box_h/3])
        rotate([90,0,0])
            cylinder(d=18, h=box_wall+2, center=true);

        // RPi4 port cutouts (back wall) — USB, HDMI, ethernet
        rpi_ox = -25;
        translate([rpi_ox-22, -box_d/2, box_wall+22])
            cube([30, box_wall+2, 18], center=true);
        translate([rpi_ox+20, -box_d/2, box_wall+18])
            cube([40, box_wall+2, 16], center=true);
        translate([rpi_ox-35, -box_d/2, box_wall+20])
            cube([20, box_wall+2, 16], center=true);

        // M4 mounting holes at corners
        for (sx=[-1,1]) for (sy=[-1,1])
            translate([sx*(box_w/2-14), sy*(box_d/2-14), -1])
                cylinder(d=4.4, h=box_wall+2);
    }
}

module underground_lid() {
    color("#404F5A", 1.0)
    difference() {
        union() {
            translate([0,0,box_lid_h/2])
                cube([box_w, box_d, box_lid_h], center=true);
            translate([0,0,box_lid_h])
            difference() {
                cube([box_w-2*box_wall-1, box_d-2*box_wall-1, 5], center=true);
                cube([box_w-2*box_wall-6, box_d-2*box_wall-6, 7], center=true);
            }
        }
        translate([-pillar_sep/2, 0, box_lid_h/2])
            cylinder(d=24, h=box_lid_h+2, center=true);
        translate([pillar_sep/2, 0, box_lid_h/2])
            cylinder(d=24, h=box_lid_h+2, center=true);
        for (sx=[-1,1]) for (sy=[-1,1])
            translate([sx*(box_w/2-14), sy*(box_d/2-14), -1])
                cylinder(d=4.4, h=box_lid_h+2);
    }
}

// ============================================================
// WALL SEGMENT (visual reference — gate wall)
// ============================================================
module gate_wall_segment(side) {
    color("#7A8A8F", 0.9)
    translate([side*(p_w/2 + 120), 0, p_h*0.4])
        cube([200, p_d*0.6, p_h*0.8], center=true);
}

// Ground plane
module ground() {
    color("#6B5A3E", 0.8)
    translate([0, 30, -10])
        cube([600, 300, 12], center=true);
}

// ============================================================
// RENDER DISPATCHER
// ============================================================

if (PART == 0) {
    ground();
    // Left pillar (camera + panel)
    translate([-pillar_sep/2, 0, 0])  tiang_kiri();
    // Right pillar (clean)
    translate([pillar_sep/2,  0, 0])  tiang_kanan();
    // Wall segments (context)
    gate_wall_segment(-1);
    gate_wall_segment(1);
    // Underground box
    translate([0, 0, box_z])          underground_box();
    translate([0, 0, -20])            underground_lid();

} else if (PART == 1) {
    tiang_kiri();
} else if (PART == 2) {
    tiang_kanan();
} else if (PART == 3) {
    underground_box();
} else if (PART == 4) {
    underground_lid();
} else if (PART == 5) {
    intercom_panel();
}

echo("=== DEFENDER Gate Pillar System ===");
echo(str("Pillar  : ", p_w, "x", p_d, "x", p_h, " mm  +  cap ", cap_h, " mm"));
echo(str("Panel   : ", panel_w, "x", panel_t, "x", panel_h, " mm  @ Z=", panel_z));
echo(str("Cam V3  : lens ", cam_lens_d, "mm  tilt -", cam_tilt, "deg"));
echo(str("Box     : ", box_w, "x", box_d, "x", box_h, " mm underground"));
echo("PART: 0=Scene 1=TiangKiri 2=TiangKanan 3=Box 4=Lid 5=Panel");
