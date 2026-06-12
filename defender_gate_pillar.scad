// ============================================================
// DEFENDER — Gate Pillar System (Tiang Pagar Moden)
// Tiang 1 (Kiri) : Pi Camera V3 dalaman + Panel Intercom
// Tiang 2 (Kanan): Buzzer + LED
// Underground Box : RPi4 + Dual 40mm Fan + lubang kabel lengkap
// ============================================================
// Pi Camera V3 : PCB 25x24mm, lens 7.4mm, FPC 16mm lebar
// RPi4         : PCB 85x56mm, standoff 58x49mm
// ============================================================
$fn = 64;

// PART SELECTOR
// 0 = Full scene
// 1 = Tiang Kiri  (kamera dalaman)
// 2 = Tiang Kanan (buzzer + LED)
// 3 = Underground Box (tanpa penutup)
// 4 = Underground Box Lid
// 5 = Panel Intercom sahaja
PART = 0;

// ============================================================
// DIMENSI TIANG
// ============================================================
p_w        = 120;
p_d        = 120;
p_h        = 350;
wall_t     = 5;
cap_w      = 138;
cap_d      = 138;
cap_h      = 28;
groove_step= 30;
groove_d   = 1.2;
groove_w   = 2.0;

// ============================================================
// PANEL INTERCOM (muka hadapan tiang kiri)
// ============================================================
panel_w    = 80;
panel_h    = 160;
panel_t    = 14;     // tebal panel (cukup untuk pemasangan dalaman)
panel_z    = 160;    // ketinggian pangkal panel dari tanah
panel_r    = 4;

// ============================================================
// PI CAMERA V3 — UKURAN SEBENAR
// Kamera dipasang DALAM panel, tiada tonjolan luar
// ============================================================
cam_pcb_w  = 25.0;   // lebar PCB sebenar
cam_pcb_d  = 24.0;   // dalam PCB sebenar
cam_pcb_t  = 1.0;    // tebal PCB
cam_lens_d = 7.4;    // diameter lubang lens
cam_fpc_w  = 16.0;   // lebar ribbon FPC
cam_fpc_t  = 2.5;    // slot FPC
cam_stoff  = 4.0;    // ketinggian standoff dalaman
cam_tilt   = 35;     // sudut bawah untuk tangkap no. plate
cam_z      = 148;    // ketinggian kamera dalam panel (dari bawah panel)

// ============================================================
// BUZZER — 12mm pasif (ukuran sebenar)
// ============================================================
buzz_d     = 12.5;
buzz_z     = 60;

// ============================================================
// LED — 5mm
// ============================================================
led_d      = 5.2;
led_z      = 88;

// ============================================================
// UNDERGROUND BOX — RPi4 + Dual Fan
// Semua lubang kabel mengikut port RPi4 sebenar
// ============================================================
box_w      = 190;    // lebar
box_d      = 130;    // dalam
box_h      = 95;     // tinggi
box_wall   = 5;
box_lid_h  = 8;

// RPi4 standoff pattern (mm dari tengah)
rpi_mnt_x  = 29.0;   // 58mm / 2
rpi_mnt_y  = 24.5;   // 49mm / 2
rpi_ox     = -28;    // offset RPi ke kiri — bagi ruang fan

// Fan 40mm
fan_r      = 17;
fan_screw  = 3.2;
fan_z      = 28;     // ketinggian pusat fan dari lantai kotak

// Port RPi4 (ukuran sebenar, pada muka belakang kotak)
// USB-A x2 (stacked): 32mm lebar x 16mm tinggi
// USB-C power: 10mm lebar x 4mm tinggi (atau grommet bulat)
// micro-HDMI x2: 12mm x 5mm setiap satu
// Ethernet: 17mm x 14mm
// GPIO: 52mm x 5mm
// 3.5mm jack: lubang bulat 7mm
rpi_base_z = box_wall + 5;   // aras PCB RPi4 dari lantai kotak

// Pillar spacing
pillar_sep = 200;
box_z      = -box_h - 20;

// ============================================================
// UTILITY MODULES
// ============================================================

module groove_lines(fw, fh, dep, gw, step) {
    n = floor(fh / step);
    for (i=[1:n])
        translate([0, -dep/2, i*step - fh/2])
            cube([fw+2, dep, gw], center=true);
}

module rounded_box(w, d, h, r) {
    hull()
        for (sx=[-1,1]) for (sy=[-1,1])
            translate([sx*(w/2-r), sy*(d/2-r), 0])
                cylinder(r=r, h=h, $fn=32);
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
    co = 18;
    for (sx=[-1,1]) for (sy=[-1,1])
        translate([sx*co, sy*co, 0])
            cylinder(d=fan_screw, h=wt+2, center=true, $fn=16);
}

// ============================================================
// PILLAR BODY
// ============================================================
module pillar_body(w, d, h) {
    difference() {
        translate([0,0,h/2]) cube([w,d,h], center=true);
        translate([0,0,wall_t+h/2]) cube([w-2*wall_t, d-2*wall_t, h], center=true);
        // Groove lines 4 muka
        translate([0, d/2, h/2])  groove_lines(w,h,groove_d,groove_w,groove_step);
        translate([0,-d/2, h/2])  rotate([0,0,180]) groove_lines(w,h,groove_d,groove_w,groove_step);
        translate([-w/2,0, h/2])  rotate([0,0,-90]) groove_lines(d,h,groove_d,groove_w,groove_step);
        translate([ w/2,0, h/2])  rotate([0,0, 90]) groove_lines(d,h,groove_d,groove_w,groove_step);
    }
}

module pillar_cap(w, d, h) {
    hull() {
        translate([0,0,0]) cube([w+4, d+4, 2], center=true);
        translate([0,0,h]) cube([w,   d,   2], center=true);
    }
}

// ============================================================
// PANEL INTERCOM
// Kamera V3 dipasang DALAM panel dengan bracket sudut tetap
// Tiada tonjolan luar — hanya lubang lens pada muka hadapan
// ============================================================
module intercom_panel() {
    color("black", 1.0)
    difference() {
        union() {
            // Badan panel
            translate([0, 0, panel_h/2])
                rounded_box(panel_w, panel_t, panel_h, panel_r);

            // Bracket dalaman kamera (rak condong 35°)
            // Bracket ini memegang PCB V3 pada sudut yang betul
            translate([0, panel_t/2 - cam_pcb_t - cam_stoff - 1, cam_z])
            rotate([-cam_tilt, 0, 0]) {
                // Pelantar PCB
                difference() {
                    cube([cam_pcb_w+6, cam_pcb_t+cam_stoff+2, cam_pcb_d+6], center=true);
                    cube([cam_pcb_w+0.5, cam_pcb_t+cam_stoff+4, cam_pcb_d+0.5], center=true);
                    cylinder(d=cam_lens_d+1, h=20, center=true);
                }
                // 4 standoff dalaman (M2, 4mm tinggi)
                for (sx=[-1,1]) for (sz=[-1,1])
                    translate([sx*10, cam_stoff/2, sz*8.5])
                    difference() {
                        cylinder(d=3.5, h=cam_stoff, center=true);
                        cylinder(d=2.0, h=cam_stoff+1, center=true, $fn=16);
                    }
            }
        }

        // Lubang lens pada muka hadapan panel (condong 35° ke bawah)
        translate([0, panel_t/2, cam_z])
        rotate([-cam_tilt, 0, 0])
        rotate([90, 0, 0])
            cylinder(d=cam_lens_d, h=panel_t+2, center=true);

        // Slot FPC ribbon (bawah lens, ke bawah panel)
        translate([0, panel_t/4, cam_z - 16])
        rotate([90,0,0])
            cube([cam_fpc_w, cam_fpc_t, panel_t+2], center=true);

        // Lubang LED
        translate([0, 0, led_z])
        rotate([90,0,0])
            cylinder(d=led_d, h=panel_t+2, center=true);

        // Lubang Buzzer
        translate([0, 0, buzz_z])
        rotate([90,0,0])
            cylinder(d=buzz_d, h=panel_t+2, center=true);

        // Pin buzzer
        for (px=[-3.5, 3.5])
            translate([px, 0, buzz_z - buzz_d/2 - 5])
            rotate([90,0,0])
                cylinder(d=1.2, h=panel_t+2, center=true, $fn=16);

        // Lubang skru pasang panel (4 penjuru)
        for (sx=[-1,1]) for (sz=[-1,1])
            translate([sx*(panel_w/2-8), 0, panel_h/2+sz*(panel_h/2-10)])
            rotate([90,0,0])
                cylinder(d=3.2, h=panel_t+2, center=true, $fn=16);

        // Saluran kabel bawah panel (FPC + wayar LED/buzzer)
        translate([0, 0, 7])
        rotate([90,0,0])
            cube([22, 16, panel_t+2], center=true);

        // Slot pengudaraan sisi kanan
        for (sz=[30,50,70])
            translate([panel_w/2, 0, sz])
            rotate([90,0,90])
                cube([3, 10, panel_t+2], center=true);
    }
}

// ============================================================
// TIANG KIRI — Kamera dalaman + Panel Intercom
// ============================================================
module tiang_kiri() {
    color("black", 1.0)
    difference() {
        union() {
            pillar_body(p_w, p_d, p_h);
            translate([0,0,p_h])  pillar_cap(cap_w, cap_d, cap_h);
            translate([0,0,-8])   cube([cap_w, cap_d, 8], center=true);
            // Recess frame untuk panel
            translate([0, p_d/2, panel_z + panel_h/2])
                cube([panel_w+2*wall_t, wall_t, panel_h+2*wall_t], center=true);
        }
        // Recess dalam muka hadapan untuk panel duduk flush
        translate([0, p_d/2+panel_t/2-0.5, panel_z+panel_h/2])
            rounded_box(panel_w+0.5, panel_t+1, panel_h+0.5, panel_r);
        // Lubang FPC + kabel turun ke bawah tanah
        translate([0, 0, 30]) cylinder(d=24, h=60, center=true);
        // Lubang kabel keluar bawah tiang (ke kotak bawah tanah)
        translate([0, -p_d/2, 22]) rotate([90,0,0])
            cylinder(d=20, h=wall_t+2, center=true);
    }
    // Panel pasang pada muka hadapan
    translate([0, p_d/2, panel_z])
        intercom_panel();
}

// ============================================================
// TIANG KANAN — Buzzer + LED sahaja
// ============================================================
module tiang_kanan() {
    color("black", 1.0)
    difference() {
        union() {
            pillar_body(p_w, p_d, p_h);
            translate([0,0,p_h])  pillar_cap(cap_w, cap_d, cap_h);
            translate([0,0,-8])   cube([cap_w, cap_d, 8], center=true);
        }
        // Lubang kabel bawah
        translate([0, 0, 30]) cylinder(d=24, h=60, center=true);
        translate([0, -p_d/2, 22]) rotate([90,0,0])
            cylinder(d=20, h=wall_t+2, center=true);
    }
}

// ============================================================
// UNDERGROUND BOX — RPi4 + Dual 40mm Fan
// Lubang kabel lengkap mengikut port RPi4 sebenar
// ============================================================
module underground_box() {
    color("black", 1.0)
    difference() {
        union() {
            // Kotak utama
            translate([0,0,box_h/2])
                cube([box_w, box_d, box_h], center=true);

            // Standoff RPi4 — 58x49mm pattern (ukuran sebenar)
            for (sx=[-1,1]) for (sy=[-1,1])
                translate([rpi_ox+sx*rpi_mnt_x, sy*rpi_mnt_y, box_wall])
                difference() {
                    cylinder(d=7, h=6);
                    cylinder(d=2.8, h=7);   // M2.5 tap
                }

            // Ridge alignment untuk penutup
            translate([0,0,box_h-box_wall-2])
            difference() {
                cube([box_w-2*box_wall-0.4, box_d-2*box_wall-0.4, box_wall+2], center=true);
                cube([box_w-2*box_wall-5,   box_d-2*box_wall-5,   box_wall+5], center=true);
            }
        }

        // Kosongkan dalam
        translate([0,0,box_wall+(box_h-box_wall)/2])
            cube([box_w-2*box_wall, box_d-2*box_wall, box_h], center=true);

        // -------------------------------------------------------
        // LUBANG KABEL — MUKA BELAKANG (port RPi4 sebenar)
        // Origin: rpi_ox dari tengah kotak, aras = rpi_base_z
        // -------------------------------------------------------

        // USB-A x2 (stacked double) — 32mm lebar x 16mm tinggi
        translate([rpi_ox-16, -box_d/2, rpi_base_z+16])
            cube([32, box_wall+2, 16], center=true);

        // USB-A x2 (set kedua) — sebelah USB pertama
        translate([rpi_ox+18, -box_d/2, rpi_base_z+16])
            cube([32, box_wall+2, 16], center=true);

        // micro-HDMI port 1 — 12mm lebar x 6mm tinggi
        translate([rpi_ox-44, -box_d/2, rpi_base_z+8])
            cube([12, box_wall+2, 6], center=true);

        // micro-HDMI port 2
        translate([rpi_ox-30, -box_d/2, rpi_base_z+8])
            cube([12, box_wall+2, 6], center=true);

        // Ethernet RJ45 — 17mm lebar x 14mm tinggi
        translate([rpi_ox+38, -box_d/2, rpi_base_z+14])
            cube([17, box_wall+2, 14], center=true);

        // USB-C power input RPi4 — grommet bulat 12mm
        translate([rpi_ox-56, -box_d/2, rpi_base_z+8])
        rotate([90,0,0])
            cylinder(d=12, h=box_wall+2, center=true);

        // 3.5mm audio jack — lubang bulat 7mm
        translate([rpi_ox-64, -box_d/2, rpi_base_z+8])
        rotate([90,0,0])
            cylinder(d=7, h=box_wall+2, center=true);

        // GPIO ribbon cable slot — 52mm x 5mm (atas PCB)
        translate([rpi_ox, -box_d/2, rpi_base_z+28])
            cube([52, box_wall+2, 6], center=true);

        // -------------------------------------------------------
        // LUBANG KUASA LUAR — Muka Belakang (bawah)
        // Bekalan kuasa utama masuk dari sini (kabel grommet 25mm)
        // -------------------------------------------------------
        translate([50, -box_d/2, 20])
        rotate([90,0,0])
            cylinder(d=25, h=box_wall+2, center=true);

        // -------------------------------------------------------
        // LUBANG KABEL ATAS — ke tiang-tiang
        // -------------------------------------------------------
        // Ke tiang kiri (FPC kamera + wayar panel)
        translate([-pillar_sep/2, 0, box_h-box_wall/2])
            cylinder(d=25, h=box_wall+2, center=true);

        // Ke tiang kanan (wayar buzzer + LED)
        translate([pillar_sep/2, 0, box_h-box_wall/2])
            cylinder(d=25, h=box_wall+2, center=true);

        // -------------------------------------------------------
        // DUAL 40mm FAN — muka kanan (exhaust)
        // -------------------------------------------------------
        for (fy=[-1,1])
            translate([box_w/2, fy*24, fan_z])
            rotate([0,90,0])
                fan_hole(box_wall);

        // Hex grille intake — muka kiri
        translate([-box_w/2, 0, fan_z])
        rotate([0,-90,0])
            hex_grid(4, 3, 5, 2, box_wall);

        // -------------------------------------------------------
        // M4 mounting bolt holes (4 penjuru bawah)
        // -------------------------------------------------------
        for (sx=[-1,1]) for (sy=[-1,1])
            translate([sx*(box_w/2-14), sy*(box_d/2-14), -1])
                cylinder(d=4.4, h=box_wall+2);
    }
}

// ============================================================
// PENUTUP (LID) UNDERGROUND BOX
// ============================================================
module underground_lid() {
    color("black", 1.0)
    difference() {
        union() {
            translate([0,0,box_lid_h/2])
                cube([box_w, box_d, box_lid_h], center=true);
            // Tab alignment
            translate([0,0,box_lid_h])
            difference() {
                cube([box_w-2*box_wall-1, box_d-2*box_wall-1, 5], center=true);
                cube([box_w-2*box_wall-6, box_d-2*box_wall-6, 7], center=true);
            }
        }
        // Lubang kabel atas (sama seperti kotak)
        translate([-pillar_sep/2, 0, box_lid_h/2])
            cylinder(d=25, h=box_lid_h+2, center=true);
        translate([pillar_sep/2, 0, box_lid_h/2])
            cylinder(d=25, h=box_lid_h+2, center=true);
        // M4 screw holes
        for (sx=[-1,1]) for (sy=[-1,1])
            translate([sx*(box_w/2-14), sy*(box_d/2-14), -1])
                cylinder(d=4.4, h=box_lid_h+2);
    }
}

// ============================================================
// PERSEKITARAN (visual context)
// ============================================================
module gate_wall(side) {
    color("#222222", 1.0)
    translate([side*(p_w/2+130), 0, p_h*0.4])
        cube([220, p_d*0.6, p_h*0.8], center=true);
}

module ground() {
    color("#333322", 0.9)
    translate([0, 30, -10])
        cube([700, 300, 12], center=true);
}

// ============================================================
// RENDER
// ============================================================
if (PART == 0) {
    ground();
    translate([-pillar_sep/2, 0, 0])  tiang_kiri();
    translate([ pillar_sep/2, 0, 0])  tiang_kanan();
    gate_wall(-1);  gate_wall(1);
    translate([0, 0, box_z])          underground_box();
    translate([0, 0, -20])            underground_lid();
} else if (PART == 1) { tiang_kiri();
} else if (PART == 2) { tiang_kanan();
} else if (PART == 3) { underground_box();
} else if (PART == 4) { underground_lid();
} else if (PART == 5) { intercom_panel();
}

echo("=== DEFENDER Gate Pillar v3 ===");
echo(str("Tiang   : ", p_w, "x", p_d, "x", p_h, "mm + cap ", cap_h, "mm"));
echo(str("Cam V3  : PCB ", cam_pcb_w, "x", cam_pcb_d, "mm  lens ", cam_lens_d, "mm  tilt -", cam_tilt, "deg (dalaman)"));
echo(str("Kotak   : ", box_w, "x", box_d, "x", box_h, "mm"));
echo("PART: 0=Scene 1=TiangKiri 2=TiangKanan 3=Box 4=Lid 5=Panel");
