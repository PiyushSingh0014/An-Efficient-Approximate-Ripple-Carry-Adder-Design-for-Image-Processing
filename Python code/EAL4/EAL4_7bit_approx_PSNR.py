#this is for 7 bit approximation for PSNR computation using EAL4 logic 

import cv2
import numpy as np
import matplotlib.pyplot as plt
import sys
import os

# ---------- USER PATHS ----------
INPUT_PATH = r"lake.tif"

# choose: "box", "laplacian", "sobel"
FILTER_TYPE = "sobel"

# Reliable output folder
COMBINED_OUTPUT = r"C:\Temp\comparison_7bit_approx.png"

# ---------- PARAMETERS ----------
N_BITS = 12
TARGET_SIZE = (512, 512)

# <<-- CHANGED TO 7 BITS HERE -->>
APPROX_BITS = 7


# =======================================================
#                EXACT carry logic (ripple)
# =======================================================
def exact_carry(Ai, Bi, Cin):
    return (Ai & Bi) | ((Ai ^ Bi) & Cin)


# =======================================================
#   Type-D OR-based approximate adder (uses APPROX_BITS)
# =======================================================
def approx_adder_case2(a, b):
    K = APPROX_BITS
    carry = 0
    result = 0

    # ---- LOWER OR PART (bits 0 .. K-2) ----
    # For K=7, this runs for bits 0, 1, 2, 3, 4, 5
    # Logic: Sum = A | B (Pure OR, no carry)
    for i in range(0, max(0, K - 1)):
        Ai = (a >> i) & 1
        Bi = (b >> i) & 1
        Si = Ai | Bi
        result |= (Si << i)

    # ---- MS approximate bit (bit K-1): OR sum, AND carry ----
    # For K=7, this is bit 6
    if K > 0:
        i = K - 1
        Ai = (a >> i) & 1
        Bi = (b >> i) & 1
        
        # LOGIC: Sum is OR, but we generate a Carry using AND
        Si = Ai | Bi
        carry = Ai & Bi
        
        result |= (Si << i)

    # ---- UPPER EXACT RIPPLE (bits K .. N_BITS-1) ----
    # For K=7, this runs for bits 7 to 11
    for i in range(K, N_BITS):
        Ai = (a >> i) & 1
        Bi = (b >> i) & 1
        
        Si = Ai ^ Bi ^ carry
        carry = exact_carry(Ai, Bi, carry)
        
        result |= (Si << i)

    # final carry-out at bit N_BITS
    result |= (carry << N_BITS)
    return result


# =======================================================
# Exact 12-bit addition (reference)
# =======================================================
def exact_adder(a, b):
    return a + b


# =======================================================
#               BOX FILTER APPROX
# =======================================================
def approx_box(img):
    H, W = img.shape
    pad = cv2.copyMakeBorder(img, 1, 1, 1, 1, cv2.BORDER_REPLICATE)
    out = np.zeros((H, W), dtype=np.uint8)

    for r in range(H):
        for c in range(W):
            acc = 0
            for i in range(-1, 2):
                for j in range(-1, 2):
                    val = int(pad[r+1+i, c+1+j])
                    acc = approx_adder_case2(acc, val)
            avg = min(255, max(0, acc // 9))
            out[r, c] = np.uint8(avg)
    return out


# =======================================================
#               APPROX LAPLACIAN
# =======================================================
def approx_laplacian(img):
    H, W = img.shape
    pad = cv2.copyMakeBorder(img, 1, 1, 1, 1, cv2.BORDER_REPLICATE)
    out = np.zeros((H, W), dtype=np.uint8)

    for r in range(H):
        for c in range(W):
            center = int(pad[r+1, c+1])
            up     = int(pad[r+0, c+1])
            down   = int(pad[r+2, c+1])
            left   = int(pad[r+1, c+0])
            right  = int(pad[r+1, c+2])

            pos = 0
            pos = approx_adder_case2(pos, up)
            pos = approx_adder_case2(pos, down)
            pos = approx_adder_case2(pos, left)
            pos = approx_adder_case2(pos, right)

            neg = 0
            for _ in range(4):
                neg = approx_adder_case2(neg, center)

            lap = abs(pos - neg)
            lap = min(255, lap)
            out[r, c] = np.uint8(lap)
    return out


# =======================================================
#                  APPROX SOBEL
# =======================================================
def approx_sobel(img):
    H, W = img.shape
    pad = cv2.copyMakeBorder(img,1,1,1,1,cv2.BORDER_REPLICATE)
    out = np.zeros((H,W),dtype=np.uint8)

    for r in range(H):
        for c in range(W):
            p00 = int(pad[r+0,c+0]); p01 = int(pad[r+0,c+1]); p02 = int(pad[r+0,c+2])
            p10 = int(pad[r+1,c+0]);                          p12 = int(pad[r+1,c+2])
            p20 = int(pad[r+2,c+0]); p21 = int(pad[r+2,c+1]); p22 = int(pad[r+2,c+2])

            # ---- Gx ----
            posx = 0
            for v in (p02, p12, p12, p22):
                posx = approx_adder_case2(posx, v)

            negx = 0
            for v in (p00, p10, p10, p20):
                negx = approx_adder_case2(negx, v)

            gx = posx - negx

            # ---- Gy ----
            posy = 0
            for v in (p20, p21, p21, p22):
                posy = approx_adder_case2(posy, v)

            negy = 0
            for v in (p00, p01, p01, p02):
                negy = approx_adder_case2(negy, v)

            gy = posy - negy

            mag = min(255, (abs(gx) + abs(gy)) // 2)
            out[r, c] = np.uint8(mag)
    return out


# =======================================================
#                  UTILITIES
# =======================================================
def read_image(path, size):
    img = cv2.imread(path, cv2.IMREAD_GRAYSCALE)
    if img is None:
        print("ERROR: Cannot open input image:", path)
        sys.exit(1)
    return cv2.resize(img, size, interpolation=cv2.INTER_AREA)

def ensure_output_dir(path):
    folder = os.path.dirname(path)
    if folder and not os.path.exists(folder):
        os.makedirs(folder, exist_ok=True)

def calculate_psnr(img1, img2, max_pixel=255.0):
    a = img1.astype(np.float64)
    b = img2.astype(np.float64)
    mse = np.mean((a - b) ** 2)
    if mse == 0:
        return float('inf')
    psnr = 10.0 * np.log10((max_pixel ** 2) / mse)
    return psnr


# =======================================================
#                      MAIN
# =======================================================
def main():
    img = read_image(INPUT_PATH, TARGET_SIZE)

    # ----------------- EXACT FILTERS -----------------
    if FILTER_TYPE == "box":
        exact = cv2.blur(img, (3,3))
        exact_title = "Exact Mean"
        approx_title = f"Approx Mean (OR-based, {APPROX_BITS}-bit)"
    elif FILTER_TYPE == "laplacian":
        l16 = cv2.Laplacian(img, cv2.CV_16S, ksize=3)
        exact = cv2.convertScaleAbs(l16)
        exact_title = "Exact Laplacian"
        approx_title = f"Approx Laplacian (OR-based, {APPROX_BITS}-bit)"
    elif FILTER_TYPE == "sobel":
        sx = cv2.Sobel(img,cv2.CV_16S,1,0,ksize=3)
        sy = cv2.Sobel(img,cv2.CV_16S,0,1,ksize=3)
        abs_sx = cv2.convertScaleAbs(sx)
        abs_sy = cv2.convertScaleAbs(sy)
        exact = cv2.addWeighted(abs_sx,0.5,abs_sy,0.5,0)
        exact_title = "Exact Sobel"
        approx_title = f"Approx Sobel (OR-based, {APPROX_BITS}-bit)"
    else:
        print("Invalid filter selection.")
        sys.exit(1)

    # ----------------- APPROX FILTERS -----------------
    print(f"Applying {FILTER_TYPE} with {APPROX_BITS}-bit approximation...")
    if FILTER_TYPE == "box":
        approx = approx_box(img)
    elif FILTER_TYPE == "laplacian":
        approx = approx_laplacian(img)
    elif FILTER_TYPE == "sobel":
        approx = approx_sobel(img)

    # ----------------- PSNRs -----------------
    psnr_oe = calculate_psnr(img, exact)
    psnr_oa = calculate_psnr(img, approx)
    psnr_ea = calculate_psnr(exact, approx)

    def pstr(v): return "inf" if np.isinf(v) else f"{v:.2f} dB"

    print("\n--------- PSNR REPORT ---------")
    print(f"Original vs Exact : {pstr(psnr_oe)}")
    print(f"Original vs Approx: {pstr(psnr_oa)}")
    print(f"Exact    vs Approx: {pstr(psnr_ea)}")
    print("--------------------------------\n")

    # ----------------- PLOTTING -----------------
    abs_error = cv2.absdiff(exact, approx)

    fig, axes = plt.subplots(2, 2, figsize=(14, 9), constrained_layout=True)

    axes[0,0].imshow(img, cmap='gray', vmin=0, vmax=255)
    axes[0,0].set_title(f"Original {TARGET_SIZE}", fontsize=12)
    axes[0,0].axis('off')

    axes[0,1].imshow(exact, cmap='gray', vmin=0, vmax=255)
    axes[0,1].set_title(f"{exact_title}", fontsize=12)
    axes[0,1].axis('off')

    axes[1,0].imshow(approx, cmap='gray', vmin=0, vmax=255)
    axes[1,0].set_title(f"{approx_title}", fontsize=12)
    axes[1,0].axis('off')

    im = axes[1,1].imshow(abs_error, cmap='hot', vmin=0, vmax=255)
    axes[1,1].set_title(
        f"Absolute Error\nPSNR(E,A): {pstr(psnr_ea)}",
        fontsize=11
    )
    axes[1,1].axis('off')
    fig.colorbar(im, ax=axes[1,1], fraction=0.046, pad=0.04)

    ensure_output_dir(COMBINED_OUTPUT)
    plt.savefig(COMBINED_OUTPUT, dpi=200, bbox_inches='tight')
    print("Saved comparison to:", COMBINED_OUTPUT)
    plt.show()

if __name__ == "__main__":
    main()