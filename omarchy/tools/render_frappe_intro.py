"""Render the Frappé background intro: a gust of wind across the lake.

Usage: python render_intro.py <base.png 2560x1440> <out.mp4> [--frames a,b,c --outdir dir]
Starts and ends exactly on the still image.
"""
import subprocess
import sys

import cv2
import numpy as np

FPS = 30
DUR = 6.5
W, H = 2560, 1440
HORIZON = 762
rng = np.random.default_rng(7)


def smoothstep(a, b, x):
    t = np.clip((x - a) / (b - a), 0.0, 1.0)
    return t * t * (3 - 2 * t)


def gust_env(t):
    return smoothstep(0.6, 1.5, t) * (1 - smoothstep(3.0, 5.4, t))


def water_env(t):
    return smoothstep(0.9, 2.1, t) * (1 - smoothstep(3.4, 5.9, t))


base = cv2.imread(sys.argv[1], cv2.IMREAD_COLOR)
assert base.shape[:2] == (H, W), base.shape
out_path = sys.argv[2]
basef = base.astype(np.float32)

yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
lum = cv2.cvtColor(base, cv2.COLOR_BGR2GRAY).astype(np.float32)


def soft(mask, k):
    return cv2.GaussianBlur(mask.astype(np.float32), (0, 0), k)


# ---------------------------------------------------------------- masks
# Water: everything below the horizon, minus the land on the right and the
# dark rocks/stones (which shouldn't wobble).
water = (yy > HORIZON + 6).astype(np.float32)
land_r = np.zeros((H, W), np.uint8)
cv2.fillPoly(land_r, [np.array([(2066, 1140), (2110, 1095), (2200, 1085), (2245, 960),
                                (2330, 900), (2360, 868), (2560, 838), (2560, 1440),
                                (2440, 1440), (2420, 1290), (2300, 1215), (2150, 1205)], np.int32)], 1)
stones = ((lum < 34) & (yy > 1120) & (xx < 900)).astype(np.uint8)
stones = cv2.dilate(stones, np.ones((9, 9), np.uint8))
water = water * (1 - land_r) * (1 - stones)
water = soft(water, 6)
depth = np.clip((yy - HORIZON) / (H - HORIZON), 0, 1)  # 0 at horizon, 1 at bottom

# Tree on the left: weight grows toward the branch tips (away from the trunk).
tree = np.zeros((H, W), np.float32)
cv2.fillPoly(tree, [np.array([(0, 220), (175, 230), (170, 330), (140, 420), (110, 520),
                               (70, 600), (0, 620)], np.int32)], 1.0)
tree = soft(tree, 14)
tree *= np.clip(xx / 170.0, 0, 1) ** 1.1 * 0.85 + 0.15
tree *= 1 - 0.6 * smoothstep(470, 600, yy)  # lower branches overlap the far mountains
# Its reflection in the water, which follows the same sway.
tree_refl = np.zeros((H, W), np.float32)
cv2.rectangle(tree_refl, (0, 880), (120, 1110), 1.0, -1)
tree_refl = soft(tree_refl, 22) * np.clip(xx / 100.0, 0, 1)

# Grass, bottom-right: two clumps, rooted at their bottom edge.
grass = np.zeros((H, W), np.float32)
grass_h = np.ones((H, W), np.float32)
for (x0, y0, x1, y1) in [(2170, 900, 2350, 1110), (1740, 1180, 2440, 1440)]:
    m = np.zeros((H, W), np.float32)
    cv2.rectangle(m, (x0, y0), (x1, y1), 1.0, -1)
    m = soft(m, 24)
    tip = np.clip((y1 - yy) / (y1 - y0), 0, 1) ** 1.4  # roots still, tips move
    grass = np.maximum(grass, m * tip)

# ---------------------------------------------------------------- leaves
N_LEAVES = 22
leaves = []
for i in range(N_LEAVES):
    lands = i < 5
    leaves.append(dict(
        t0=rng.uniform(1.0, 2.7),
        x=rng.uniform(60, 290), y=rng.uniform(300, 600),
        vx=rng.uniform(380, 700) * (0.75 if lands else 1.0),
        vy=rng.uniform(-50, 40),
        g=rng.uniform(150, 230) if lands else rng.uniform(25, 90),
        size=rng.uniform(6.0, 10.5),
        spin=rng.uniform(2, 5) * rng.choice([-1, 1]),
        flip=rng.uniform(3, 7),
        phase=rng.uniform(0, 6.28),
        land_y=rng.uniform(880, 1080) if lands else None,
        landed=None,
    ))


def leaf_pos(L, t):
    dt = t - L["t0"]
    x = L["x"] + L["vx"] * dt + 30 * np.sin(2.2 * dt + L["phase"])
    y = L["y"] + L["vy"] * dt + 0.5 * L["g"] * dt * dt + 18 * np.sin(3.1 * dt + L["phase"])
    return x, y


# Pre-simulate landings so the ring ripples know where/when to start.
rings = []
for L in leaves:
    if L["land_y"] is None:
        continue
    for f in range(int(DUR * FPS)):
        t = f / FPS
        if t < L["t0"]:
            continue
        x, y = leaf_pos(L, t)
        if y >= L["land_y"]:
            if 0 < x < 2000 and t < 4.2:
                L["landed"] = t
                rings.append((x, y, t))
            else:
                L["landed"] = t  # off-target: just vanish
            break

LEAF_COLOR = np.array([22, 16, 20], np.float32)  # BGR, matches the tree silhouette


def draw_leaves(img, t):
    overlay = np.zeros((H, W), np.float32)
    for L in leaves:
        if t < L["t0"]:
            continue
        if L["landed"] is not None and t >= L["landed"]:
            continue
        dt = t - L["t0"]
        fade_in = smoothstep(0, 0.25, dt)
        fade_out = 1 - smoothstep(3.0, 3.6, dt)
        a = float(fade_in * fade_out)
        if a <= 0.01:
            continue
        x, y = leaf_pos(L, t)
        if x > W + 40 or y > H + 40:
            continue
        ang = L["spin"] * dt + L["phase"]
        length = L["size"]
        width = length * (0.12 + 0.30 * abs(np.cos(L["flip"] * dt + L["phase"])))
        u = np.linspace(-1, 1, 9)
        half = width * (1 - u ** 2)  # pointed at both ends
        pts = np.concatenate([np.stack([u * length, half], 1), np.stack([u[::-1] * length, -half[::-1]], 1)])
        rot = np.array([[np.cos(ang), -np.sin(ang)], [np.sin(ang), np.cos(ang)]])
        for k, w in ((0.0, 1.0), (0.014, 0.35)):
            px, py = leaf_pos(L, t - k)
            poly = (pts @ rot.T + [px, py]) * 4
            cv2.fillPoly(overlay, [poly.astype(np.int32)], a * w, cv2.LINE_AA, shift=2)
    overlay = np.clip(overlay, 0, 1)[..., None]
    return img * (1 - overlay * 0.92) + LEAF_COLOR * overlay * 0.92


# ---------------------------------------------------------------- displacement
def displacement(t):
    dx = np.zeros((H, W), np.float32)
    dy = np.zeros((H, W), np.float32)

    g = gust_env(t)
    we = water_env(t)

    if we > 0:
        # Wind ripples: a gust front sweeps left->right; wavelength shrinks
        # toward the horizon (perspective), amplitude grows toward the viewer.
        front = -600 + 1100 * (t - 0.9)
        band = smoothstep(front - 1400, front - 200, xx) * (1 - smoothstep(front, front + 500, xx))
        band = np.maximum(band, smoothstep(front - 200, front + 300, xx) * 0)  # (front edge only)
        coverage = np.where(xx < front, 1.0, band).astype(np.float32)
        # wavelength grows from ~5px at the horizon to ~46px at the bottom
        lam_a, lam_b = 5.0, 41.0
        phase_y = 2 * np.pi * (H - HORIZON) / lam_b * np.log(lam_a + lam_b * depth)
        phase = phase_y + 0.003 * xx - 6.0 * t
        amp = we * (1.2 + 10.0 * depth) * coverage
        cat = 0.55 + 0.45 * np.sin(0.005 * xx + 0.011 * yy - 1.7 * t)  # cat's-paw patches
        wobble = 0.7 * np.sin(phase) + 0.3 * np.sin(1.73 * phase_y - 0.002 * xx - 8.3 * t + 0.8)
        dx += amp * cat * wobble * water
        dy += 0.35 * amp * cat * np.sin(phase + 1.3) * water

    for (rx, ry, rt) in rings:
        age = t - rt
        if age <= 0 or age > 3.2:
            continue
        persp = 0.18 + 0.6 * (ry - HORIZON) / (H - HORIZON)  # flatten rings near horizon
        ddx = xx - rx
        ddy = (yy - ry) / persp
        r = np.sqrt(ddx * ddx + ddy * ddy) + 1e-3
        speed = 140.0
        front_r = speed * age
        wave = np.sin(0.09 * (r - front_r)) * np.exp(-((r - front_r) / 60.0) ** 2)
        decay = np.exp(-age * 1.1) * (1 - smoothstep(2.4, 3.2, age))
        a = 5.0 * decay
        dx += a * wave * ddx / r * water
        dy += a * wave * (ddy / r) * persp * water

    if g > 0:
        # Tree: pushed right by the gust plus a swaying oscillation.
        sway = g * (0.55 + 0.45 * np.sin(2 * np.pi * 1.15 * t + yy * 0.012))
        flutter = g * 1.4 * np.sin(2 * np.pi * 3.7 * t + xx * 0.05 + yy * 0.03)
        dx += -(9.0 * sway + flutter) * tree  # negative: sample from the left = move right
        dy += -(2.0 * g * np.sin(2 * np.pi * 1.6 * t + xx * 0.02)) * tree
        dx += -(5.0 * sway) * tree_refl
        # Grass: travelling wave left->right, tips bend with the gust.
        gw = g * (0.6 + 0.4 * np.sin(2 * np.pi * 0.9 * t - xx * 0.006))
        dx += -(11.0 * gw + 2.0 * g * np.sin(2 * np.pi * 2.9 * t + xx * 0.04)) * grass
    return dx, dy


def frame(t):
    if gust_env(t) == 0 and water_env(t) == 0 and not any(
            0 < t - rt <= 3.2 for (_, _, rt) in rings) and not any(
            L["t0"] <= t and (L["landed"] is None or t < L["landed"]) and t - L["t0"] < 3.6 for L in leaves):
        return base
    dx, dy = displacement(t)
    img = cv2.remap(basef, xx + dx, yy + dy, cv2.INTER_LINEAR, borderMode=cv2.BORDER_REFLECT)
    # Tiny crest shimmer on the water while it moves.
    we = water_env(t)
    if we > 0:
        img *= (1 + 0.02 * np.clip(dx / 8.0, -1, 1) * water)[..., None]
    img = draw_leaves(img, t)
    return np.clip(img, 0, 255).astype(np.uint8)


n = int(round(DUR * FPS))
if "--frames" in sys.argv:
    want = [int(v) for v in sys.argv[sys.argv.index("--frames") + 1].split(",")]
    outdir = sys.argv[sys.argv.index("--outdir") + 1]
    for f in want:
        cv2.imwrite(f"{outdir}/f{f:03d}.png", frame(f / FPS))
    sys.exit(0)

ff = subprocess.Popen([
    "ffmpeg", "-v", "error", "-y", "-f", "rawvideo", "-pix_fmt", "bgr24", "-s", f"{W}x{H}",
    "-r", str(FPS), "-i", "-", "-c:v", "libx264", "-preset", "slow", "-crf", "18",
    "-pix_fmt", "yuv420p", "-movflags", "+faststart", out_path], stdin=subprocess.PIPE)
for f in range(n):
    ff.stdin.write(frame(f / FPS).tobytes())
    if f % 30 == 0:
        print(f"frame {f}/{n}", flush=True)
ff.stdin.close()
ff.wait()
print("rings:", [(round(x), round(y), round(t, 2)) for x, y, t in rings])
