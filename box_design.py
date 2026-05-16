import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, Arc, Circle, FancyArrowPatch
from matplotlib.lines import Line2D
import matplotlib.patheffects as pe
import numpy as np

plt.rcParams['font.family'] = ['DejaVu Sans', 'sans-serif']

# ─────────────────────────────────────────────────────────
# FIGURE 1 – Isometric / Exploded View
# ─────────────────────────────────────────────────────────
fig1, ax = plt.subplots(1, 1, figsize=(14, 10), facecolor='#1a1a2e')
ax.set_facecolor('#1a1a2e')
ax.set_xlim(0, 14)
ax.set_ylim(0, 10)
ax.axis('off')
ax.set_aspect('equal')

def iso_pt(x, y, z, ox=2.5, oy=2.5, scale=0.9):
    ix = ox + (x - z) * scale * 0.707
    iy = oy + (y + (x + z) * 0.5) * scale * 0.5
    return ix, iy

def draw_iso_box(ax, x0, y0, z0, W, D, H, face_color, edge_color, alpha=0.85, label=None):
    verts = {
        'A': iso_pt(x0,     y0,     z0),
        'B': iso_pt(x0+W,   y0,     z0),
        'C': iso_pt(x0+W,   y0,     z0+D),
        'D': iso_pt(x0,     y0,     z0+D),
        'E': iso_pt(x0,     y0+H,   z0),
        'F': iso_pt(x0+W,   y0+H,   z0),
        'G': iso_pt(x0+W,   y0+H,   z0+D),
        'GH':iso_pt(x0,     y0+H,   z0+D),
    }
    # Bottom face
    bot = plt.Polygon([verts['A'], verts['B'], verts['C'], verts['D']],
                      closed=True, facecolor=face_color, edgecolor=edge_color,
                      linewidth=1.2, alpha=alpha*0.6)
    # Left face
    left = plt.Polygon([verts['A'], verts['D'], verts['GH'], verts['E']],
                       closed=True, facecolor=face_color, edgecolor=edge_color,
                       linewidth=1.2, alpha=alpha*0.8)
    # Right face
    right = plt.Polygon([verts['D'], verts['C'], verts['G'], verts['GH']],
                        closed=True, facecolor=face_color, edgecolor=edge_color,
                        linewidth=1.2, alpha=alpha)
    # Top face
    top = plt.Polygon([verts['E'], verts['F'], verts['G'], verts['GH']],
                      closed=True, facecolor=face_color, edgecolor=edge_color,
                      linewidth=1.2, alpha=alpha*1.1 if alpha*1.1<=1 else 1)
    for face in [bot, left, right, top]:
        ax.add_patch(face)
    if label:
        cx, cy = iso_pt(x0+W/2, y0+H/2, z0+D)
        ax.text(cx+0.1, cy+0.05, label, color='white', fontsize=7.5,
                ha='center', va='center', fontweight='bold',
                path_effects=[pe.withStroke(linewidth=2, foreground='black')])
    return verts

# Draw outer sleeve (white)
draw_iso_box(ax, 0, 0, 0, 8.5, 4.6, 4.1, '#e8e8e0', '#b0b0b0', alpha=0.55)

# Draw inner tray (dark, slightly pulled out)
draw_iso_box(ax, 0.2, 0.15, 0.2, 8.0, 4.2, 3.7, '#2a2a3e', '#4a7aff', alpha=0.9)

# Pi board inside tray
draw_iso_box(ax, 0.5, 0.2, 0.5, 4.2, 3.2, 0.85, '#1a6b3a', '#00ff88', alpha=0.95, label='Pi 4+')

# Heatsink tower
draw_iso_box(ax, 1.0, 1.05, 1.5, 2.9, 2.9, 1.8, '#888888', '#aaaaaa', alpha=0.8, label='Heatsink')

# Fan 1
draw_iso_box(ax, 1.0, 2.85, 1.5, 2.9, 0.12, 1.8, '#cccccc', '#4a7aff', alpha=0.7, label='Fan×2')

# Camera module
draw_iso_box(ax, 5.3, 0.5, 0.8, 1.3, 1.5, 1.0, '#8855cc', '#bb88ff', alpha=0.9, label='Cam V3')

# Wire area
draw_iso_box(ax, 5.3, 0.5, 2.1, 1.3, 1.5, 1.2, '#cc8833', '#ffaa55', alpha=0.7, label='Wires')

# Ventilation holes on side
for i in range(5):
    xv = 3.5 + i * 0.22
    yv = 4.8 + i * 0.11 - 0.2
    ax.plot([xv, xv+0.06], [yv, yv+0.03], color='#4a7aff', lw=2.5, alpha=0.8)

# Dimension arrows
def dim_arrow(ax, x1, y1, x2, y2, label, color='#ffdd44'):
    ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle='<->', color=color, lw=1.5))
    mx, my = (x1+x2)/2, (y1+y2)/2
    ax.text(mx, my+0.18, label, color=color, fontsize=8, ha='center',
            fontweight='bold',
            path_effects=[pe.withStroke(linewidth=2, foreground='black')])

# Title
ax.text(7, 9.5, 'I DEFENDER  —  Box Design', color='white', fontsize=16,
        ha='center', fontweight='bold', fontstyle='italic')
ax.text(7, 9.1, 'Isometric Exploded View', color='#4a7aff', fontsize=10, ha='center')

# Legend
legend_items = [
    patches.Patch(color='#e8e8e0', label='Outer Sleeve  182×92×82 mm'),
    patches.Patch(color='#2a2a3e', label='Inner Tray  176×86×75 mm'),
    patches.Patch(color='#1a6b3a', label='Raspberry Pi 4+'),
    patches.Patch(color='#888888', label='Dual Fan Heatsink'),
    patches.Patch(color='#8855cc', label='Pi Camera V3'),
    patches.Patch(color='#cc8833', label='Wire Bundle'),
]
ax.legend(handles=legend_items, loc='lower right', fontsize=8,
          facecolor='#0d0d1a', edgecolor='#4a7aff', labelcolor='white',
          framealpha=0.9)

# Circuit trace decoration
for i in range(3):
    x_s = 9.5 + i * 1.2
    pts = [(x_s, 1.0), (x_s+0.4, 1.0), (x_s+0.4, 1.5), (x_s+0.8, 1.5)]
    xs = [p[0] for p in pts]
    ys = [p[1] for p in pts]
    ax.plot(xs, ys, color='#4a7aff', lw=0.8, alpha=0.4)
    ax.plot(x_s+0.8, 1.5, 'o', color='#4a7aff', ms=3, alpha=0.5)

plt.tight_layout()
plt.savefig('/home/user/dataai-Landing/box_design_1_isometric.png',
            dpi=150, bbox_inches='tight', facecolor='#1a1a2e')
plt.close()
print("Figure 1 saved")

# ─────────────────────────────────────────────────────────
# FIGURE 2 – Cutting Templates (Nets)
# ─────────────────────────────────────────────────────────
fig2, axes = plt.subplots(1, 2, figsize=(16, 9), facecolor='#fafaf5')
fig2.suptitle('I DEFENDER Box  —  Cutting Templates (1:1 scale guide)',
               fontsize=14, fontweight='bold', color='#1a1a2e', y=0.98)

# ── LEFT: Inner Tray net ──
ax2 = axes[0]
ax2.set_facecolor('#fafaf5')
ax2.set_xlim(-10, 300)
ax2.set_ylim(-10, 250)
ax2.set_aspect('equal')
ax2.set_title('① Inner Tray Net  (3 mm corrugated board)\nSheet: 290 × 230 mm',
              fontsize=10, color='#cc4400', pad=8, fontweight='bold')
ax2.axis('off')

# Tray dimensions
W_tray = 170  # internal length
D_tray = 80   # internal width
H_tray = 75   # height
t = 3         # cardboard thickness

# Net: center bottom, flaps fold up
# Bottom rect starts at (H_tray, H_tray) = (75, 75)
bx, by = H_tray, H_tray  # bottom-left of base

# Base
base = patches.Rectangle((bx, by), W_tray, D_tray,
                          linewidth=1.5, edgecolor='#1a1a2e',
                          facecolor='#e8f4fd', linestyle='--')
ax2.add_patch(base)
ax2.text(bx+W_tray/2, by+D_tray/2, f'BASE\n{W_tray}×{D_tray} mm',
         ha='center', va='center', fontsize=9, color='#1a1a2e', fontweight='bold')

# Long side flaps (top and bottom of net)
for fy, label in [(by-H_tray, 'LONG SIDE A'), (by+D_tray, 'LONG SIDE B')]:
    flap = patches.Rectangle((bx, fy), W_tray, H_tray,
                              linewidth=1.5, edgecolor='#1a1a2e',
                              facecolor='#d4edda', linestyle='-')
    ax2.add_patch(flap)
    ax2.text(bx+W_tray/2, fy+H_tray/2, f'{label}\n{W_tray}×{H_tray} mm',
             ha='center', va='center', fontsize=8, color='#155724')
    # Fold line
    fy2 = by if fy < by else by+D_tray
    ax2.plot([bx, bx+W_tray], [fy2, fy2], color='#cc4400', lw=1.5,
             linestyle=':', label='_nolegend_')

# Short end flaps (left and right of net)
short_W = D_tray - 2*t  # 74mm
for fx, label in [(bx-H_tray, 'END A'), (bx+W_tray, 'END B')]:
    flap = patches.Rectangle((fx, by), H_tray, D_tray,
                              linewidth=1.5, edgecolor='#1a1a2e',
                              facecolor='#fff3cd', linestyle='-')
    ax2.add_patch(flap)
    ax2.text(fx+H_tray/2, by+D_tray/2, f'{label}\n{H_tray}×{D_tray}',
             ha='center', va='center', fontsize=7.5, color='#856404')
    fx2 = bx if fx < bx else bx+W_tray
    ax2.plot([fx2, fx2], [by, by+D_tray], color='#cc4400', lw=1.5, linestyle=':')

# Corner cut indicators
corner_size = H_tray
corners = [
    (bx-H_tray, by-H_tray),
    (bx+W_tray, by-H_tray),
    (bx-H_tray, by+D_tray),
    (bx+W_tray, by+D_tray),
]
for cx_, cy_ in corners:
    cut = patches.Rectangle((cx_, cy_), H_tray, H_tray,
                             linewidth=1, edgecolor='#999', facecolor='#eee',
                             linestyle='--', hatch='///')
    ax2.add_patch(cut)
    ax2.text(cx_+H_tray/2, cy_+H_tray/2, '✂ CUT\nAWAY',
             ha='center', va='center', fontsize=7, color='#666')

# Dimension annotations
def dim_h(ax, x1, x2, y, label, offset=-6, color='#1a1a2e'):
    ax.annotate('', xy=(x2, y+offset), xytext=(x1, y+offset),
                arrowprops=dict(arrowstyle='<->', color=color, lw=1.2))
    ax.text((x1+x2)/2, y+offset-7, label, ha='center', va='top',
            fontsize=8, color=color)
    ax.plot([x1, x1], [y, y+offset], color=color, lw=0.8, linestyle=':')
    ax.plot([x2, x2], [y, y+offset], color=color, lw=0.8, linestyle=':')

def dim_v(ax, y1, y2, x, label, offset=8, color='#1a1a2e'):
    ax.annotate('', xy=(x+offset, y2), xytext=(x+offset, y1),
                arrowprops=dict(arrowstyle='<->', color=color, lw=1.2))
    ax.text(x+offset+5, (y1+y2)/2, label, ha='left', va='center',
            fontsize=8, color=color, rotation=90)
    ax.plot([x, x+offset], [y1, y1], color=color, lw=0.8, linestyle=':')
    ax.plot([x, x+offset], [y2, y2], color=color, lw=0.8, linestyle=':')

dim_h(ax2, bx, bx+W_tray, by-H_tray, '170 mm', offset=-8, color='#cc4400')
dim_v(ax2, by, by+D_tray, bx+W_tray+H_tray, '80 mm', offset=8, color='#cc4400')
dim_v(ax2, by-H_tray, by, bx-H_tray, '75 mm', offset=-30, color='#0066cc')

# Legend for fold lines
ax2.plot([15, 45], [5, 5], color='#cc4400', lw=1.5, linestyle=':')
ax2.text(50, 5, '= Fold line', fontsize=8, va='center', color='#cc4400')
ax2.plot([120, 150], [5, 5], color='#1a1a2e', lw=1.5, linestyle='-')
ax2.text(155, 5, '= Cut line', fontsize=8, va='center', color='#1a1a2e')

# ── RIGHT: Outer Sleeve net ──
ax3 = axes[1]
ax3.set_facecolor('#fafaf5')
ax3.set_xlim(-10, 440)
ax3.set_ylim(-10, 250)
ax3.set_aspect('equal')
ax3.set_title('② Outer Sleeve Panels  (2 mm greyboard)\n5 panels glued together — one end open',
              fontsize=10, color='#005588', pad=8, fontweight='bold')
ax3.axis('off')

# Sleeve dimensions
W_sl = 182
D_sl = 92
H_sl = 82
t2 = 2

panels = [
    (0,   60,  W_sl, D_sl, '#dce8f7', '① TOP PANEL\n182 × 92 mm', '#005588'),
    (0,  160,  W_sl, D_sl, '#dce8f7', '② BOTTOM PANEL\n182 × 92 mm', '#005588'),
    (200, 10,  W_sl, H_sl, '#fde8d8', '③ FRONT LONG SIDE\n182 × 82 mm', '#883300'),
    (200, 105, W_sl, H_sl, '#fde8d8', '④ BACK LONG SIDE\n182 × 82 mm', '#883300'),
    (395, 60,  D_sl-2*t2, H_sl-2*t2, '#e8f7dc',
     '⑤ CLOSED END\n88 × 78 mm', '#336600'),
]

for px, py, pw, ph, fc, lbl, tc in panels:
    p = patches.Rectangle((px, py), pw, ph,
                           linewidth=1.5, edgecolor='#333',
                           facecolor=fc, linestyle='-')
    ax3.add_patch(p)
    ax3.text(px+pw/2, py+ph/2, lbl, ha='center', va='center',
             fontsize=8, color=tc, fontweight='bold',
             multialignment='center')

# Ventilation cutout on front long side (panel ③)
vent_x = 200 + 55
vent_y = 10 + 25
vent = patches.FancyBboxPatch((vent_x, vent_y), 70, 30,
                               boxstyle='round,pad=2',
                               linewidth=1.5, edgecolor='#4a7aff',
                               facecolor='#c8d8ff', linestyle='-')
ax3.add_patch(vent)
ax3.text(vent_x+35, vent_y+15, '✦ VENT\n70×30 mm\n(× both sides)',
         ha='center', va='center', fontsize=7, color='#0033cc',
         fontweight='bold')

# Cable holes on closed end panel ⑤
hole_x, hole_y = 395, 60
for i, (hw, hh, hlbl) in enumerate([(12,10,'USB-C\nØ12'),(20,8,'HDMI\n20×8'),(18,15,'ETH\n18×15')]):
    hx = hole_x + 8
    hy = hole_y + 10 + i*22
    h = patches.FancyBboxPatch((hx, hy), hw, hh,
                                boxstyle='round,pad=1',
                                linewidth=1, edgecolor='#333',
                                facecolor='#fff0c0')
    ax3.add_patch(h)
    ax3.text(hx+hw+3, hy+hh/2, hlbl, va='center', fontsize=6.5, color='#555')

# Open end arrow
ax3.annotate('Open end\n(tray entry)', xy=(200+W_sl, 10+H_sl/2),
             xytext=(200+W_sl+20, 10+H_sl/2),
             arrowprops=dict(arrowstyle='->', color='#cc4400', lw=1.5),
             fontsize=8, color='#cc4400', va='center')

# Glue sequence note
ax3.text(200, 200,
         'Assembly order:  ① Glue ③+④ to ①  →  Add ②  →  Glue ⑤ on one end',
         fontsize=8.5, color='#333',
         bbox=dict(boxstyle='round', facecolor='#fff9e6', edgecolor='#ccc', alpha=0.9))

plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('/home/user/dataai-Landing/box_design_2_templates.png',
            dpi=150, bbox_inches='tight', facecolor='#fafaf5')
plt.close()
print("Figure 2 saved")

# ─────────────────────────────────────────────────────────
# FIGURE 3 – Cross-section & Component Layout
# ─────────────────────────────────────────────────────────
fig3, axes3 = plt.subplots(2, 2, figsize=(14, 10), facecolor='#0d0d1a')
fig3.suptitle('I DEFENDER  —  Internal Layout & Section Views',
              fontsize=14, fontweight='bold', color='white', y=0.99)

# ── Top-view cross section ──
ax_top = axes3[0, 0]
ax_top.set_facecolor('#141428')
ax_top.set_xlim(-5, 185)
ax_top.set_ylim(-5, 95)
ax_top.set_aspect('equal')
ax_top.set_title('Top View (Cross-Section)', color='white', fontsize=10, pad=6)
ax_top.tick_params(colors='white')
for sp in ax_top.spines.values():
    sp.set_color('#444')
ax_top.set_xlabel('mm', color='#aaa', fontsize=8)
ax_top.set_ylabel('mm', color='#aaa', fontsize=8)
ax_top.tick_params(labelcolor='#aaa', labelsize=7)

# Outer box outline
outer_top = patches.Rectangle((0, 0), 182, 92, linewidth=2,
                               edgecolor='#aaaaaa', facecolor='#2a2a2a', zorder=1)
ax_top.add_patch(outer_top)
# Inner tray
inner_top = patches.Rectangle((3, 3), 176, 86, linewidth=1.5,
                               edgecolor='#4a7aff', facecolor='#1e1e3a', zorder=2)
ax_top.add_patch(inner_top)

# Pi PCB zone
pi_zone = patches.Rectangle((8, 8), 100, 76, linewidth=1.5,
                             edgecolor='#00ff88', facecolor='#0a2a1a', zorder=3)
ax_top.add_patch(pi_zone)
ax_top.text(58, 46, 'Pi 4+\n85×56mm\n(PCB)', ha='center', va='center',
            color='#00ff88', fontsize=8, fontweight='bold')

# Heatsink outline (centered on Pi)
hs = patches.Rectangle((19, 19), 60, 58, linewidth=1,
                        edgecolor='#888', facecolor='#333', zorder=4, linestyle='--')
ax_top.add_patch(hs)
ax_top.text(49, 48, 'Heatsink\n58×58', ha='center', va='center',
            color='#aaa', fontsize=7)

# Camera zone
cam_zone = patches.Rectangle((118, 25), 30, 30, linewidth=1.5,
                              edgecolor='#bb88ff', facecolor='#2a1a3a', zorder=3)
ax_top.add_patch(cam_zone)
ax_top.text(133, 40, 'CAM\nV3', ha='center', va='center',
            color='#bb88ff', fontsize=8, fontweight='bold')

# Wire zone
wire_zone = patches.Rectangle((118, 58), 55, 26, linewidth=1.5,
                               edgecolor='#ffaa55', facecolor='#2a1a0a', zorder=3)
ax_top.add_patch(wire_zone)
ax_top.text(145, 71, 'Wires / Cables', ha='center', va='center',
            color='#ffaa55', fontsize=7.5)

# Vent slots on top/bottom walls
for vx in [35, 55, 75]:
    for vy in [0.2, 90.2]:
        ax_top.add_patch(patches.Rectangle((vx, vy), 12, 2,
                         facecolor='#4a7aff', edgecolor='none', zorder=5))

# Dimension lines
ax_top.annotate('', xy=(182, -3), xytext=(0, -3),
                arrowprops=dict(arrowstyle='<->', color='#ffdd44', lw=1.2))
ax_top.text(91, -3, '182 mm', ha='center', va='top', fontsize=8,
            color='#ffdd44', fontweight='bold')
ax_top.annotate('', xy=(-3, 92), xytext=(-3, 0),
                arrowprops=dict(arrowstyle='<->', color='#ffdd44', lw=1.2))
ax_top.text(-3, 46, '92 mm', ha='right', va='center', fontsize=8,
            color='#ffdd44', fontweight='bold', rotation=90)

# ── Front section view ──
ax_front = axes3[0, 1]
ax_front.set_facecolor('#141428')
ax_front.set_xlim(-5, 185)
ax_front.set_ylim(-5, 90)
ax_front.set_aspect('equal')
ax_front.set_title('Front View (Section A-A)', color='white', fontsize=10, pad=6)
ax_front.tick_params(colors='white')
for sp in ax_front.spines.values():
    sp.set_color('#444')
ax_front.set_xlabel('mm', color='#aaa', fontsize=8)
ax_front.set_ylabel('mm', color='#aaa', fontsize=8)
ax_front.tick_params(labelcolor='#aaa', labelsize=7)

# Outer sleeve front view
outer_f = patches.Rectangle((0, 0), 182, 82, linewidth=2,
                             edgecolor='#aaa', facecolor='#1e1e1e', zorder=1)
ax_front.add_patch(outer_f)

# Inner tray cross section
tray_f = patches.Rectangle((3, 3), 176, 76, linewidth=1.5,
                            edgecolor='#4a7aff', facecolor='#1e1e3a', zorder=2)
ax_front.add_patch(tray_f)

# Pi board cross section
pi_f = patches.Rectangle((8, 8), 100, 17, linewidth=1,
                          edgecolor='#00ff88', facecolor='#0a2a0a', zorder=3)
ax_front.add_patch(pi_f)
ax_front.text(58, 16, 'Pi 4+ PCB  17mm', ha='center', va='center',
              color='#00ff88', fontsize=7)

# Heatsink
hs_f = patches.Rectangle((19, 25), 60, 40, linewidth=1,
                          edgecolor='#888', facecolor='#333', zorder=3)
ax_front.add_patch(hs_f)
ax_front.text(49, 45, 'Heatsink\n40mm', ha='center', va='center',
              color='#aaa', fontsize=7)

# Fans on top of heatsink
fan1 = patches.Rectangle((23, 65), 24, 8, linewidth=1,
                          edgecolor='#4a7aff', facecolor='#0a0a3a', zorder=4)
fan2 = patches.Rectangle((51, 65), 24, 8, linewidth=1,
                          edgecolor='#4a7aff', facecolor='#0a0a3a', zorder=4)
ax_front.add_patch(fan1)
ax_front.add_patch(fan2)
ax_front.text(49, 69, 'Fan 1    Fan 2', ha='center', va='center',
              color='#4a7aff', fontsize=6.5)

# Camera
cam_f = patches.Rectangle((120, 30), 25, 25, linewidth=1.5,
                           edgecolor='#bb88ff', facecolor='#2a0a3a', zorder=3)
ax_front.add_patch(cam_f)
lens_c = Circle((132, 42), 8, linewidth=1.5, edgecolor='#bb88ff',
                facecolor='#0a0a2a', zorder=4)
ax_front.add_patch(lens_c)
ax_front.text(132, 42, '●', ha='center', va='center', color='#8888ff', fontsize=8)
ax_front.text(132, 20, 'Camera\nV3', ha='center', va='center',
              color='#bb88ff', fontsize=7)

# Ventilation slot in front wall
vent_f = patches.Rectangle((35, 0), 70, 2, facecolor='#4a7aff',
                            edgecolor='none', zorder=5)
ax_front.add_patch(vent_f)
ax_front.text(70, -3, 'Vent slots', ha='center', va='top',
              color='#4a7aff', fontsize=7)

# Height dim
ax_front.annotate('', xy=(-3, 82), xytext=(-3, 0),
                  arrowprops=dict(arrowstyle='<->', color='#ffdd44', lw=1.2))
ax_front.text(-3, 41, '82 mm', ha='right', va='center',
              color='#ffdd44', fontsize=8, rotation=90)
ax_front.annotate('', xy=(182, -3), xytext=(0, -3),
                  arrowprops=dict(arrowstyle='<->', color='#ffdd44', lw=1.2))
ax_front.text(91, -3, '182 mm', ha='center', va='top',
              color='#ffdd44', fontsize=8, fontweight='bold')

# ── Side section view ──
ax_side = axes3[1, 0]
ax_side.set_facecolor('#141428')
ax_side.set_xlim(-5, 100)
ax_side.set_ylim(-5, 90)
ax_side.set_aspect('equal')
ax_side.set_title('Side View (Section B-B) + Vent Detail', color='white', fontsize=10, pad=6)
ax_side.tick_params(colors='white')
for sp in ax_side.spines.values():
    sp.set_color('#444')
ax_side.set_xlabel('mm', color='#aaa', fontsize=8)
ax_side.set_ylabel('mm', color='#aaa', fontsize=8)
ax_side.tick_params(labelcolor='#aaa', labelsize=7)

# Outer shell side
outer_s = patches.Rectangle((0, 0), 92, 82, linewidth=2,
                             edgecolor='#aaa', facecolor='#1e1e1e')
ax_side.add_patch(outer_s)

# Inner tray
tray_s = patches.Rectangle((3, 3), 86, 76, linewidth=1.5,
                            edgecolor='#4a7aff', facecolor='#1e1e3a')
ax_side.add_patch(tray_s)

# Pi (side view)
pi_s = patches.Rectangle((8, 8), 76, 17, linewidth=1,
                          edgecolor='#00ff88', facecolor='#0a2a0a')
ax_side.add_patch(pi_s)
ax_side.text(46, 16, 'Pi 4+', ha='center', va='center',
             color='#00ff88', fontsize=8)

# Heatsink (side)
hs_s = patches.Rectangle((17, 25), 58, 40, linewidth=1,
                          edgecolor='#888', facecolor='#333')
ax_side.add_patch(hs_s)
ax_side.text(46, 45, 'Heatsink', ha='center', va='center', color='#aaa', fontsize=8)

# Fan (side)
fan_s = patches.Rectangle((17, 65), 58, 8, linewidth=1,
                           edgecolor='#4a7aff', facecolor='#0a0a3a')
ax_side.add_patch(fan_s)
ax_side.text(46, 69, 'Fan', ha='center', va='center',
             color='#4a7aff', fontsize=7)

# Vent holes in side wall (right side of box = top of this view)
for vx in [20, 35, 50, 65]:
    vslot = patches.Rectangle((vx, 80), 10, 2, facecolor='#4a7aff', edgecolor='none')
    ax_side.add_patch(vslot)
ax_side.text(46, 84, 'Vent ×4  (10×3 mm slots)', ha='center',
             va='bottom', color='#4a7aff', fontsize=7)

# Dim
ax_side.annotate('', xy=(92, -3), xytext=(0, -3),
                 arrowprops=dict(arrowstyle='<->', color='#ffdd44', lw=1.2))
ax_side.text(46, -3, '92 mm', ha='center', va='top', color='#ffdd44', fontsize=8)
ax_side.annotate('', xy=(-3, 82), xytext=(-3, 0),
                 arrowprops=dict(arrowstyle='<->', color='#ffdd44', lw=1.2))
ax_side.text(-3, 41, '82 mm', ha='right', va='center',
             color='#ffdd44', fontsize=8, rotation=90)

# ── Material & BOM table ──
ax_bom = axes3[1, 1]
ax_bom.set_facecolor('#141428')
ax_bom.axis('off')
ax_bom.set_title('Bill of Materials & Notes', color='white', fontsize=10, pad=6)

bom_data = [
    ['#', 'Material', 'Size', 'Qty', 'Use'],
    ['1', '3mm Corrugated Board', 'A3 (297×420)', '1', 'Inner Tray'],
    ['2', '2mm Greyboard', 'A3 (297×420)', '2', 'Outer Sleeve'],
    ['3', 'White Art Paper 120g', 'A3', '1', 'Outer Wrap'],
    ['4', 'Dark Paper / Vinyl', 'A4', '1', 'Tray Wrap'],
    ['5', 'Hot Glue Sticks', '—', '5+', 'Assembly'],
    ['6', '5mm EVA Foam Sheet', 'A5', '1', 'Component Pad'],
    ['7', 'Plastic Mesh / Grille', '8×3 cm', '2', 'Vent Cover'],
    ['8', 'Neodymium Magnet', 'Ø6mm', '4', 'Closure'],
    ['9', 'Ribbon Cable Clip', '3mm slot', '1', 'Cam Cable'],
]

table = ax_bom.table(
    cellText=bom_data[1:],
    colLabels=bom_data[0],
    cellLoc='center',
    loc='center',
    bbox=[0, 0.35, 1, 0.6]
)
table.auto_set_font_size(False)
table.set_fontsize(7.5)
for (row, col), cell in table.get_celld().items():
    if row == 0:
        cell.set_facecolor('#2a3a5a')
        cell.set_text_props(color='white', fontweight='bold')
    else:
        cell.set_facecolor('#1e1e3a' if row % 2 else '#18182e')
        cell.set_text_props(color='#dddddd')
    cell.set_edgecolor('#444')

# Notes
notes = [
    '★  Airflow: Fans face UP — top vent essential',
    '★  Foam cutouts shaped per component footprint',
    '★  Camera ribbon exits through 25×3 mm slot (top)',
    '★  Magnet closure: 2 on tray edge, 2 in sleeve',
    '★  Final outer: 182 × 92 × 82 mm  |  Weight ≈ 120 g',
]
for i, note in enumerate(notes):
    ax_bom.text(0.02, 0.30 - i*0.058, note, transform=ax_bom.transAxes,
               color='#88ccff', fontsize=8, va='top',
               fontfamily='monospace')

plt.tight_layout(rect=[0, 0, 1, 0.97])
plt.savefig('/home/user/dataai-Landing/box_design_3_sections.png',
            dpi=150, bbox_inches='tight', facecolor='#0d0d1a')
plt.close()
print("Figure 3 saved")
print("All figures generated successfully!")
