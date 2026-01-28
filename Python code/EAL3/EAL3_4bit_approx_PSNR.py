#this is for PSNR computation of 4bit approximation using EAL 3 logic 
import cv2
import numpy as np
import matplotlib.pyplot as plt
import sys
import os

# ---------- USER PATHS ----------
INPUT_PATH = r"lake.tif"

# choose: "box", "laplacian", "sobel"
FILTER_TYPE = "sobel"

# reliable output folder (will be created if missing)
COMBINED_OUTPUT = r"C:\Temp\comparison_2x2.png"

# ---------- PARAMETERS ----------
N_BITS = 12
TARGET_SIZE = (512, 512)
APPROX_BITS = 4   # now using LXOA with lower 4 bits approximated

# =======================================================
#                EXACT carry logic (ripple)
# =======================================================
def exact_carry(Ai, Bi, Cin):
    return (Ai & Bi) | ((Ai ^ Bi) & Cin)

# (kept for compatibility; not used by the LXOA block)
def carry_case2(Ai, Bi):
    return Ai & Bi

# =======================================================
#   Hybrid Approximate Adder (LXOA rule using APPROX_BITS)
#   Pattern (for K = APPROX_BITS):
#     bits 0 .. K-2 : S[i] = A[i] | B[i]
#     bit K-1       : S[K-1] = A[K-1] ^ B[K-1]; carry = A[K-1] & B[K-1]
#     bits K .. N_BITS-1: exact ripple with carry as Cin
# =======================================================
def approx_adder_case2(a, b):
    """
    LXOA-based approximate adder:
    - a, b: integers to be added (assumed to fit within N_BITS bits in practice)
    - uses global APPROX_BITS to decide approximation width (K)
    Returns integer sum with final carry placed at bit N_BITS.
    """
    K = APPROX_BITS
    carry = 0
    result = 0

    # ---- LOWER APPROX REGION: bits 0 .. K-2 (OR) ----
    # If K <= 1 this loop does nothing
    for i in range(0, max(0, K - 1)):
        Ai = (a >> i) & 1
        Bi = (b >> i) & 1
        Si = Ai | Bi            # OR-approx (no carry propagation from these bits)
        result |= (Si << i)

    # ---- MOST-SIGNIFICANT APPROX BIT: bit K-1 (XOR for sum, AND for carry) ----
    if K > 0:
        i = K - 1
        Ai = (a >> i) & 1
        Bi = (b >> i) & 1
        Si = Ai ^ Bi            # XOR sum
        carry = Ai & Bi        # AND => carry-out into the exact region
        result |= (Si << i)

    # ---- UPPER EXACT RIPPLE PART: bits K .. N_BITS-1 ----
    for i in range(K, N_BITS):
        Ai = (a >> i) & 1
        Bi = (b >> i) & 1
        Si = Ai ^ Bi ^ carry
        carry = exact_carry(Ai, Bi, carry)
        result |= (Si << i)

    # ---- final carry-out (bit N_BITS) ----
    result |= (carry << N_BITS)

    return result

# =======================================================
# Exact 12-bit addition (reference)
# =======================================================
def exact_adder(a, b):
    return a + b

# =======================================================
#                   BOX FILTER APPROX (uses approx adder)
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

            avg = acc // 9
            avg = min(255, max(0, avg))
            out[r, c] = np.uint8(avg)

    return out

# =======================================================
#               APPROX LAPLACIAN (4-neighbor)
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

            # positive neighbors
            pos = 0
            pos = approx_adder_case2(pos, up)
            pos = approx_adder_case2(pos, down)
            pos = approx_adder_case2(pos, left)
            pos = approx_adder_case2(pos, right)

            # 4 * center
            neg = 0
            neg = approx_adder_case2(neg, center)
            neg = approx_adder_case2(neg, center)
            neg = approx_adder_case2(neg, center)
            neg = approx_adder_case2(neg, center)

            lap = pos - neg
            lap = min(255, max(0, abs(lap)))

            out[r, c] = np.uint8(lap)

    return out

# =======================================================
#                     APPROX SOBEL
# =======================================================
def approx_sobel(img):
    H, W = img.shape
    pad = cv2.copyMakeBorder(img,1,1,1,1,cv2.BORDER_REPLICATE)

    out = np.zeros((H,W),dtype=np.uint8)

    for r in range(H):
        for c in range(W):

            p00 = int(pad[r+0,c+0])
            p01 = int(pad[r+0,c+1])
            p02 = int(pad[r+0,c+2])

            p10 = int(pad[r+1,c+0])
            p12 = int(pad[r+1,c+2])

            p20 = int(pad[r+2,c+0])
            p21 = int(pad[r+2,c+1])
            p22 = int(pad[r+2,c+2])

            # ---- Gx ----
            posx = 0
            posx = approx_adder_case2(posx, p02)
            posx = approx_adder_case2(posx, p12)
            posx = approx_adder_case2(posx, p12)
            posx = approx_adder_case2(posx, p22)

            negx = 0
            negx = approx_adder_case2(negx, p00)
            negx = approx_adder_case2(negx, p10)
            negx = approx_adder_case2(negx, p10)
            negx = approx_adder_case2(negx, p20)

            gx = int(posx) - int(negx)

            # ---- Gy ----
            posy = 0
            posy = approx_adder_case2(posy, p20)
            posy = approx_adder_case2(posy, p21)
            posy = approx_adder_case2(posy, p21)
            posy = approx_adder_case2(posy, p22)

            negy = 0
            negy = approx_adder_case2(negy, p00)
            negy = approx_adder_case2(negy, p01)
            negy = approx_adder_case2(negy, p01)
            negy = approx_adder_case2(negy, p02)

            gy = int(posy) - int(negy)

            mag = (abs(gx) + abs(gy)) // 2
            mag = min(255, mag)

            out[r, c] = np.uint8(mag)

    return out

# =======================================================
#                     READ + PREPARE
# =======================================================
def read_image(path, size):
    img = cv2.imread(path, cv2.IMREAD_GRAYSCALE)
    if img is None:
        print("ERROR: Cannot open input image:", path)
        sys.exit(1)
    return cv2.resize(img, size, interpolation=cv2.INTER_AREA)

# =======================================================
#                  ensure output folder
# =======================================================
def ensure_output_dir(path):
    folder = os.path.dirname(path)
    if folder and not os.path.exists(folder):
        os.makedirs(folder, exist_ok=True)

# =======================================================
#                   PSNR CALCULATION
# =======================================================
def calculate_psnr(img1, img2, max_pixel=255.0):
    a = img1.astype(np.float64)
    b = img2.astype(np.float64)
    mse = np.mean((a - b) ** 2)
    if mse == 0:
        return float('inf')
    psnr = 10.0 * np.log10((max_pixel ** 2) / mse)
    return psnr

# =======================================================
#                          MAIN
# =======================================================
def main():

    img = read_image(INPUT_PATH, TARGET_SIZE)

    # ----------------- EXACT FILTERS -----------------
    if FILTER_TYPE == "box":
        exact = cv2.blur(img, (3,3))
        exact_title = "Exact Mean"
        approx_title = f"Approx Mean (LXOA, {APPROX_BITS}-bit)"
    elif FILTER_TYPE == "laplacian":
        l16 = cv2.Laplacian(img, cv2.CV_16S, ksize=3)
        exact = cv2.convertScaleAbs(l16)
        exact_title = "Exact Laplacian"
        approx_title = f"Approx Laplacian (LXOA, {APPROX_BITS}-bit)"
    elif FILTER_TYPE == "sobel":
        sx = cv2.Sobel(img,cv2.CV_16S,1,0,ksize=3)
        sy = cv2.Sobel(img,cv2.CV_16S,0,1,ksize=3)
        abs_sx = cv2.convertScaleAbs(sx)
        abs_sy = cv2.convertScaleAbs(sy)
        exact = cv2.addWeighted(abs_sx,0.5,abs_sy,0.5,0)
        exact_title = "Exact Sobel"
        approx_title = f"Approx Sobel (LXOA, {APPROX_BITS}-bit)"
    else:
        print("Invalid filter selection: choose 'box', 'laplacian' or 'sobel'.")
        sys.exit(1)

    # ----------------- APPROX FILTERS -----------------
    if FILTER_TYPE == "box":
        approx = approx_box(img)
    elif FILTER_TYPE == "laplacian":
        approx = approx_laplacian(img)
    elif FILTER_TYPE == "sobel":
        approx = approx_sobel(img)

    # ----------------- PSNRs -----------------
    psnr_orig_exact = calculate_psnr(img, exact)
    psnr_orig_approx = calculate_psnr(img, approx)
    psnr_exact_approx = calculate_psnr(exact, approx)

    def psnr_to_str(v):
        return "inf" if np.isinf(v) else f"{v:.2f} dB"

    psnr_oe = psnr_to_str(psnr_orig_exact)
    psnr_oa = psnr_to_str(psnr_orig_approx)
    psnr_ea = psnr_to_str(psnr_exact_approx)

    # Print PSNR report to console
    print("\n--------- PSNR REPORT ---------")
    print(f"Original  vs Exact : {psnr_oe}")
    print(f"Original  vs Approx: {psnr_oa}")
    print(f"Exact     vs Approx: {psnr_ea}")
    print("--------------------------------\n")

    # ----------------- ERROR MAP -----------------
    abs_error = cv2.absdiff(exact, approx)

    # ----------------- PANEL -----------------
    fig, axes = plt.subplots(2, 2, figsize=(14, 9), constrained_layout=True)

    axes[0,0].imshow(img, cmap='gray', vmin=0, vmax=255)
    axes[0,0].set_title(f"Original {TARGET_SIZE[0]}×{TARGET_SIZE[1]}", fontsize=12)
    axes[0,0].axis('off')

    axes[0,1].imshow(exact, cmap='gray', vmin=0, vmax=255)
    axes[0,1].set_title(f"{exact_title} {TARGET_SIZE[0]}×{TARGET_SIZE[1]}", fontsize=12)
    axes[0,1].axis('off')

    axes[1,0].imshow(approx, cmap='gray', vmin=0, vmax=255)
    axes[1,0].set_title(f"{approx_title} {TARGET_SIZE[0]}×{TARGET_SIZE[1]}", fontsize=12)
    axes[1,0].axis('off')

    im = axes[1,1].imshow(abs_error, cmap='hot', vmin=0, vmax=255)
    axes[1,1].set_title(
        f"Absolute Error\nPSNR(O,E): {psnr_oe}   PSNR(O,A): {psnr_oa}   PSNR(E,A): {psnr_ea}",
        fontsize=11
    )
    axes[1,1].axis('off')

    # colorbar positioned for the error plot
    fig.colorbar(im, ax=axes[1,1], fraction=0.046, pad=0.04)

    # save and show
    ensure_output_dir(COMBINED_OUTPUT)
    plt.savefig(COMBINED_OUTPUT, dpi=200, bbox_inches='tight', pad_inches=0.5)
    print("Saved combined comparison to:", COMBINED_OUTPUT)

    plt.show()

if __name__ == "__main__":
    main()
