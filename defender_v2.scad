// ============================================================
// DEFENDER v2 — Dual Stone Pillar System
// Tiang 1: Pi Camera V3 | Tiang 2: Buzzer + LED
// Underground Box: Raspberry Pi 4 + Dual Fan + Heatsink
// ============================================================
// Pi Camera V3 actual dims: PCB 25x24mm, lens ~7.4mm dia
// RPi4 actual dims: 85x56mm PCB
// ============================================================
$fn = 64;

// ============================================================
// PART SELECTOR
// 0 = Full scene (both pillars + underground box)
// 1 = Tiang Kamera (Camera Pillar)
// 2 = Tiang Buzzer + LED
// 3 = Underground Box (lid off)
// 4 = Underground Box Lid
// ============================================================
PART = 0;

// ============================================================
// PILLAR DIMENSIONS (stone aesthetic, slim for camera only)
// ============================================================
p_w       = 60;     // Pillar width  (X)
p_d       = 50;     // Pillar depth  (Y)
p_h       = 250;    // Pillar height (Z)
p_wall    = 4;      // Wall thickness
p_chamfer = 5;      // Stone edge bevel
groove_step = 25;   // Stone block joint spacing
groove_d  = 1.0;    // Groove depth
groove_w  = 1.6;    // Groove width

// ============================================================
// PI CAMERA V3 — ACTUAL MEASUREMENTS
// ============================================================
cam_pcb_w  = 25;    // Camera PCB width  (actual)
cam_pcb_d  = 24;    // Camera PCB depth  (actual)
cam_pcb_t  = 1.0;   // PCB thickness
cam_lens_d = 7.4;   // Lens opening diameter (actual IMX708)
cam_fpc_w  = 16;    // FPC ribbon cable width
cam_fpc_t  = 2;     // FPC slot thickness
cam_height = p_h - 40;  // Lens centre height from ground

// ============================================================
// BUZZER — 12mm passive buzzer (actual)
// ============================================================
buzz_d     = 12.5;  // Buzzer diameter
buzz_h     = 9.5;   // Buzzer height
buzz_pin   = 1.0;   // Pin hole diameter

// ============================================================
// LED — 5mm LED with chrome bezel
// ============================================================
led_d      = 5.2;   // LED hole diameter (5mm LED + clearance)
led_bezel  = 8;     // Chrome bezel outer diameter

// ============================================================
// UNDERGROUND BOX — RPi4 + Dual Fan
// ============================================================
box_w     = 160;    // Box width  (X)  — RPi4 85mm + fans 2x40mm
box_d     = 110;    // Box depth  (Y)  — RPi4 56mm + clearance
box_h     = 85;     // Box height (Z)  — RPi4 + heatsink + fan
box_wall  = 4;      // Box wall thickness
box_lid_h = 6;      // Lid thickness

// RPi4 actual PCB mounting hole pattern: 58mm x 49mm
rpi_mnt_x = 58 / 2;
rpi_mnt_y = 49 / 2;

// Fan 40mm
fan_r     = 17;     // Fan airflow hole radius
fan_screw = 3.2;    // Fan screw hole

// ============================================================
// SCENE LAYOUT
// ============================================================
pillar_sep = 120;   // Distance between two pillars
box_depth  = -40;   // Underground box Z position (below ground)

// ============================================================
// UTILITIES
// ============================================================

module chamfered_box(w, d, h, c) {
    minkowski() {
        cube([w-2*c, d-2*c, h-2*c], center=true);
        sphere(r=c, $fn=8);
    }
}

module stone_grooves(face_w, face_h, dep, gw, step) {
    num = floor(face_h / step);
    for (i = [1:num]) {
        translate([0, -dep/2, i*step - face_h/2])
            cube([face_w+2, dep, gw], center=true);
    }
}

module hex_prism(r, h) { cylinder(r=r, h=h, $fn=6); }

module hex_grid(cols, rows, r, gap, depth) {
    sx = r*2 + gap;
    sy = r*sqrt(3) + gap;
    for (row=[0:rows-1]) for (col=[0:cols-1]) {
        ox = (row%2==1) ? sx/2 : 0;
        translate([col*sx + ox - (cols-1)*sx/2,
                   row*sy - (rows-1)*sy/2, 0])
            hex_prism(r, depth+1);
    }
}

module m4_boss(h) {
    difference() {
        cylinder(d=10, h=h);
        cylinder(d=4.4, h=h+1);
    }
}

module fan_hole(wall_t) {
    cylinder(r=fan_r, h=wall_t+2, center=true);
    co = 40/2 - 4;
    for (sx=[-1,1]) for (sy=[-1,1])
        translate([sx*co, sy*co, 0])
            cylinder(d=fan_screw, h=wall_t+2, center=true, $fn=16);
}

// ============================================================
// PILLAR SHELL — shared base for both pillars
// ============================================================

module pillar_shell(w, d, h) {
    difference() {
        translate([0,0,h/2])
            chamfered_box(w, d, h, p_chamfer);
        // Hollow
        translate([0,0,p_wall + h/2])
            cube([w-2*p_wall, d-2*p_wall, h+1], center=true);
        // Stone grooves — 4 faces
        translate([0, d/2, h/2])
            stone_grooves(w, h, groove_d, groove_w, groove_step);
        translate([0, -d/2, h/2])
        rotate([0,0,180])
            stone_grooves(w, h, groove_d, groove_w, groove_step);
        translate([-w/2, 0, h/2])
        rotate([0,0,-90])
            stone_grooves(d, h, groove_d, groove_w, groove_step);
        translate([w/2, 0, h/2])
        rotate([0,0,90])
            stone_grooves(d, h, groove_d, groove_w, groove_step);
    }
}

// ============================================================
// TIANG 1 — PI CAMERA V3
// ============================================================

module tiang_kamera() {
    color("SlateGray", 0.95)
    difference() {
        union() {
            // Main pillar shell
            pillar_shell(p_w, p_d, p_h);

            // Camera front hood / visor (protective overhang above lens)
            visor_z = cam_height + cam_lens_d/2 + 4;
            translate([0, p_d/2 - p_wall/2, visor_z])
            rotate([-8, 0, 0]) {
                translate([0, 10, 3])
                    cube([p_w - 2*p_chamfer, 20, 5], center=true);
                // Gusset left
                translate([-(p_w/2 - p_chamfer - 3), 5, 1.5])
                    linear_extrude(4)
                        polygon([[0,0],[0,18],[-4,0]]);
                // Gusset right
                translate([(p_w/2 - p_chamfer - 3), 5, 1.5])
                    linear_extrude(4)
                        polygon([[0,0],[0,18],[4,0]]);
            }

            // Camera PCB retention frame (inside pillar)
            translate([0, p_d/2 - p_wall - 1, cam_height])
            difference() {
                cube([cam_pcb_w+8, p_wall+2, cam_pcb_d+8], center=true);
                cube([cam_pcb_w+0.5, p_wall+4, cam_pcb_d+0.5], center=true);
                cylinder(d=cam_lens_d+1, h=p_wall+5, center=true);
            }

            // Base mounting bosses (4x M4)
            for (sx=[-1,1]) for (sy=[-1,1])
                translate([sx*(p_w/2-10), sy*(p_d/2-10), 0])
                    m4_boss(8);
        }

        // ---- CUTOUTS ----
        // Lens hole (front face)
        translate([0, p_d/2, cam_height])
        rotate([90,0,0])
            cylinder(d=cam_lens_d, h=p_wall+2, center=true);

        // Camera PCB pocket behind front wall
        translate([0, p_d/2 - p_wall - 1.5, cam_height])
            cube([cam_pcb_w+0.5, 3, cam_pcb_d+0.5], center=true);

        // FPC ribbon cable slot (below camera)
        translate([0, p_d/2, cam_height - cam_pcb_d/2 - 4])
        rotate([90,0,0])
            cube([cam_fpc_w, cam_fpc_t, p_wall+2], center=true);

        // Cable routing hole through base (FPC down to underground)
        translate([0, 0, 15])
            cylinder(d=20, h=30, center=true);

        // M4 clearance at base
        for (sx=[-1,1]) for (sy=[-1,1])
            translate([sx*(p_w/2-10), sy*(p_d/2-10), -1])
                cylinder(d=4.4, h=12);

        // Hex ventilation back face (lower section for airflow)
        translate([0, -p_d/2, p_h/4])
        rotate([0,0,180]) rotate([90,0,0])
            hex_grid(3, 3, 4, 2, p_wall);
    }
}

// ============================================================
// TIANG 2 — BUZZER + LED
// ============================================================

module tiang_buzzer_led() {
    color("DimGray", 0.95)
    difference() {
        union() {
            pillar_shell(p_w, p_d, p_h);

            // Buzzer protective recess frame (front face)
            buzz_z = p_h * 0.65;
            translate([0, p_d/2, buzz_z])
            difference() {
                cube([buzz_d+14, p_wall+4, buzz_d+14], center=true);
                cylinder(d=buzz_d+0.5, h=p_wall+6, center=true);
            }

            // LED protective collar (front face, above buzzer)
            led_z = p_h * 0.78;
            translate([0, p_d/2, led_z])
            difference() {
                cylinder(d=led_bezel+6, h=p_wall+4, center=true);
                cylinder(d=led_d, h=p_wall+6, center=true);
            }

            // Wire channel inside pillar (vertical trunking)
            translate([0, p_d/2 - p_wall - 5, p_h/2])
            difference() {
                cube([10, 8, p_h-2*p_wall], center=true);
                cube([8, 6, p_h], center=true);
            }

            // Base mounting bosses
            for (sx=[-1,1]) for (sy=[-1,1])
                translate([sx*(p_w/2-10), sy*(p_d/2-10), 0])
                    m4_boss(8);
        }

        // ---- CUTOUTS ----
        // Buzzer hole
        buzz_z = p_h * 0.65;
        translate([0, p_d/2, buzz_z])
        rotate([90,0,0])
            cylinder(d=buzz_d, h=p_wall+2, center=true);

        // Buzzer pin holes
        for (px=[-3, 3])
            translate([px, p_d/2, buzz_z - buzz_d/2 - 3])
            rotate([90,0,0])
                cylinder(d=1.2, h=p_wall+2, center=true, $fn=16);

        // LED hole
        led_z = p_h * 0.78;
        translate([0, p_d/2, led_z])
        rotate([90,0,0])
            cylinder(d=led_d, h=p_wall+2, center=true);

        // Wire cable hole through base
        translate([0, 0, 15])
            cylinder(d=20, h=30, center=true);

        // M4 clearance at base
        for (sx=[-1,1]) for (sy=[-1,1])
            translate([sx*(p_w/2-10), sy*(p_d/2-10), -1])
                cylinder(d=4.4, h=12);

        // Hex ventilation back face
        translate([0, -p_d/2, p_h/4])
        rotate([0,0,180]) rotate([90,0,0])
            hex_grid(3, 3, 4, 2, p_wall);

        // Label emboss area (front face)
        translate([0, p_d/2, p_h*0.35])
        rotate([90,0,0])
            linear_extrude(0.6)
                text("DEFENDER", size=5, halign="center", valign="center");
    }
}

// ============================================================
// UNDERGROUND BOX — RPi4 + Dual Fan + Heatsink
// ============================================================

module underground_box() {
    color("DarkOliveGreen", 0.9)
    difference() {
        union() {
            // Main box
            translate([0,0,box_h/2])
                chamfered_box(box_w, box_d, box_h, 3);

            // RPi4 PCB standoffs (actual 58x49mm hole pattern)
            rpi_ox = -20;  // offset RPi to left to make room for fans
            rpi_oy = 0;
            for (sx=[-1,1]) for (sy=[-1,1])
                translate([rpi_ox + sx*rpi_mnt_x,
                           rpi_oy + sy*rpi_mnt_y,
                           box_wall])
                difference() {
                    cylinder(d=6, h=5);
                    cylinder(d=2.8, h=6);
                }

            // Lid alignment lip (inside top edge)
            translate([0,0,box_h - box_wall - 2])
            difference() {
                cube([box_w - 2*box_wall - 0.4,
                      box_d - 2*box_wall - 0.4,
                      box_wall+2], center=true);
                cube([box_w - 2*box_wall - 4,
                      box_d - 2*box_wall - 4,
                      box_wall+4], center=true);
            }
        }

        // Hollow interior
        translate([0,0,box_wall + (box_h-box_wall)/2])
            cube([box_w - 2*box_wall,
                  box_d - 2*box_wall,
                  box_h], center=true);

        // Dual 40mm fan holes — right side wall (exhaust)
        fan_z = box_wall + 5 + 20;  // fan centre height
        for (fy=[-1,1])
            translate([box_w/2, fy*25, fan_z])
            rotate([0,90,0])
                fan_hole(box_wall);

        // Hex intake grille — left side wall
        translate([-box_w/2, 0, fan_z])
        rotate([0,-90,0])
            hex_grid(4, 3, 5, 2, box_wall);

        // Cable entry holes for pillars (top face)
        translate([-pillar_sep/2, 0, box_h - box_wall/2])
            cylinder(d=22, h=box_wall+2, center=true);
        translate([pillar_sep/2, 0, box_h - box_wall/2])
            cylinder(d=22, h=box_wall+2, center=true);

        // Power cable entry (bottom)
        translate([0, -box_d/2+10, box_h/3])
        rotate([90,0,0])
            cylinder(d=16, h=box_wall+2, center=true);

        // USB-A port cutout (back face — RPi4 actual position)
        rpi_ox = -20;
        translate([rpi_ox-22, -box_d/2, box_wall+5+18])
            cube([30, box_wall+2, 18], center=true);
        // HDMI + USB-C cutout
        translate([rpi_ox+18, -box_d/2, box_wall+5+14])
            cube([36, box_wall+2, 14], center=true);
        // Ethernet
        translate([rpi_ox-32, -box_d/2, box_wall+5+16])
            cube([18, box_wall+2, 16], center=true);

        // M4 mounting holes (4 corners, bolt box underground)
        for (sx=[-1,1]) for (sy=[-1,1])
            translate([sx*(box_w/2-12), sy*(box_d/2-12), -1])
                cylinder(d=4.4, h=box_wall+2);
    }
}

module underground_lid() {
    color("DarkOliveGreen", 0.85)
    difference() {
        union() {
            translate([0,0,box_lid_h/2])
                chamfered_box(box_w, box_d, box_lid_h, 3);
            // Alignment tab (fits inside box lip)
            translate([0,0,box_lid_h])
            difference() {
                cube([box_w - 2*box_wall - 1,
                      box_d - 2*box_wall - 1, 4], center=true);
                cube([box_w - 2*box_wall - 5,
                      box_d - 2*box_wall - 5, 6], center=true);
            }
        }
        // Cable holes matching box top
        translate([-pillar_sep/2, 0, box_lid_h/2])
            cylinder(d=22, h=box_lid_h+2, center=true);
        translate([pillar_sep/2, 0, box_lid_h/2])
            cylinder(d=22, h=box_lid_h+2, center=true);
        // M4 screw holes
        for (sx=[-1,1]) for (sy=[-1,1])
            translate([sx*(box_w/2-12), sy*(box_d/2-12), -1])
                cylinder(d=4.4, h=box_lid_h+2);
    }
}

// ============================================================
// GROUND PLANE (visual reference only)
// ============================================================
module ground_plane() {
    color("SaddleBrown", 0.3)
    translate([0, 0, -2])
        cube([400, 300, 4], center=true);
}

// ============================================================
// RENDER DISPATCHER
// ============================================================

if (PART == 0) {
    // Full scene
    ground_plane();

    // Tiang 1 — Kamera (left)
    translate([-pillar_sep/2, 0, 0])
        tiang_kamera();

    // Tiang 2 — Buzzer+LED (right)
    translate([pillar_sep/2, 0, 0])
        tiang_buzzer_led();

    // Underground box (centered, below ground)
    translate([0, 0, box_depth - box_h])
        underground_box();

    // Underground lid
    translate([0, 0, box_depth])
        underground_lid();

    // FPC cable lines (visual guide)
    color("Orange", 0.7)
    translate([-pillar_sep/2, 0, 0]) {
        translate([0, p_d/2 - p_wall - 2, cam_height - cam_pcb_d/2 - 10])
        rotate([0,0,0])
            cube([cam_fpc_w, 1, cam_height - cam_pcb_d/2 - 10], center=false);
    }

} else if (PART == 1) {
    tiang_kamera();
} else if (PART == 2) {
    tiang_buzzer_led();
} else if (PART == 3) {
    underground_box();
} else if (PART == 4) {
    underground_lid();
}

// Console info
echo("=== DEFENDER v2 — Dual Pillar System ===");
echo(str("Pillar dims  : ", p_w, "W x ", p_d, "D x ", p_h, "H mm"));
echo(str("Pi Cam V3    : PCB ", cam_pcb_w, "x", cam_pcb_d, "mm | Lens ", cam_lens_d, "mm"));
echo(str("Underground  : ", box_w, "W x ", box_d, "D x ", box_h, "H mm"));
echo(str("Pillar gap   : ", pillar_sep, "mm"));
echo("PART 0=Scene 1=CamPillar 2=BuzzLED 3=Box 4=Lid");
