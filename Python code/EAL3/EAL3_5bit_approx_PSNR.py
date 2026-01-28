#this is for 5bit approximation for PSNR computation for EAL3 logic 
import cv2
import numpy as np
import matplotlib.pyplot as plt
import sys
import os

# ---------- USER PATHS ----------
INPUT_PATH = r"lake.tif"

# choose: "box", "laplacian", "sobel"
FILTER_TYPE = "laplacian"

# reliable output folder (will be created if missing)
COMBINED_OUTPUT = r"C:\Temp\comparison_2x2.png"

# ---------- PARAMETERS ----------
N_BITS = 12
TARGET_SIZE = (512, 512)
APPROX_BITS = 5   # <<< NOW USING 5-BIT LXOA APPROXIMATION

# =======================================================
#                EXACT carry logic (ripple)
# =======================================================
def exact_carry(Ai, Bi, Cin):
    return (Ai & Bi) | ((Ai ^ Bi) & Cin)

def carry_case2(Ai, Bi):
    return Ai & Bi

# =======================================================
#   LXOA Approximate Adder (generic for APPROX_BITS)
#   bits 0 .. K-2 : OR
#   bit K-1       : XOR + AND (carry)
#   bits K..11    : exact ripple
# =======================================================
def approx_adder_case2(a, b):
    K = APPROX_BITS
    carry = 0
    result = 0

    # ---- lower OR region ----
    for i in range(0, max(0, K - 1)):
        Ai = (a >> i) & 1
        Bi = (b >> i) & 1
        Si = Ai | Bi
        result |= (Si << i)

    # ---- MS approximation bit ----
    if K > 0:
        i = K - 1
        Ai = (a >> i) & 1
        Bi = (b >> i) & 1
        Si = Ai ^ Bi
        carry = Ai & Bi
        result |= (Si << i)

    # ---- upper exact ripple ----
    for i in range(K, N_BITS):
        Ai = (a >> i) & 1
        Bi = (b >> i) & 1
        Si = Ai ^ Bi ^ carry
        carry = exact_carry(Ai, Bi, carry)
        result |= (Si << i)

    # final carry-out
    result |= (carry << N_BITS)
    return result

# =======================================================
#                   EXACT ADDER
# =======================================================
def exact_adder(a, b):
    return a + b

# =======================================================
#                   BOX FILTER APPROX
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
#                       APPROX SOBEL
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
#                IMAGE READ
# =======================================================
def read_image(path, size):
    img = cv2.imread(path, cv2.IMREAD_GRAYSCALE)
    if img is None:
        print("ERROR: Cannot open:", path)
        sys.exit(1)
    return cv2.resize(img, size)

# =======================================================
#             ENSURE OUTPUT DIR
# =======================================================
def ensure_output_dir(path):
    folder = os.path.dirname(path)
    if folder and not os.path.exists(folder):
        os.makedirs(folder)

# =======================================================
#                  PSNR
# =======================================================
def calculate_psnr(img1, img2, max_pixel=255.0):
    a = img1.astype(np.float64)
    b = img2.astype(np.float64)
    mse = np.mean((a - b)**2)
    if mse == 0:
        return float("inf")
    return 10*np.log10((max_pixel**2)/mse)

# =======================================================
#                      MAIN
# =======================================================
def main():

    img = read_image(INPUT_PATH, TARGET_SIZE)

    # ----- exact reference -----
    if FILTER_TYPE == "box":
        exact = cv2.blur(img,(3,3))
        approx_title = f"Approx Mean (LXOA, {APPROX_BITS}-bit)"
        exact_title  = "Exact Mean"

    elif FILTER_TYPE == "laplacian":
        l16 = cv2.Laplacian(img, cv2.CV_16S)
        exact = cv2.convertScaleAbs(l16)
        approx_title = f"Approx Laplacian (LXOA, {APPROX_BITS}-bit)"
        exact_title  = "Exact Laplacian"

    elif FILTER_TYPE == "sobel":
        sx = cv2.Sobel(img,cv2.CV_16S,1,0)
        sy = cv2.Sobel(img,cv2.CV_16S,0,1)
        exact = cv2.addWeighted(
            cv2.convertScaleAbs(sx),0.5,
            cv2.convertScaleAbs(sy),0.5,0)
        approx_title = f"Approx Sobel (LXOA, {APPROX_BITS}-bit)"
        exact_title  = "Exact Sobel"

    # ----- approx filter -----
    if FILTER_TYPE == "box":
        approx = approx_box(img)
    elif FILTER_TYPE == "laplacian":
        approx = approx_laplacian(img)
    elif FILTER_TYPE == "sobel":
        approx = approx_sobel(img)

    # ----- PSNR -----
    psnr_oe = calculate_psnr(img, exact)
    psnr_oa = calculate_psnr(img, approx)
    psnr_ea = calculate_psnr(exact, approx)

    print("\n--------- PSNR REPORT (5-BIT LXOA) ---------")
    print(f"Orig vs Exact : {psnr_oe:.2f} dB")
    print(f"Orig vs Approx: {psnr_oa:.2f} dB")
    print(f"Exact vs Approx: {psnr_ea:.2f} dB")
    print("--------------------------------------------\n")

    abs_error = cv2.absdiff(exact, approx)

    # ----- show results -----
    fig, axes = plt.subplots(2,2,figsize=(14,9),constrained_layout=True)

    axes[0,0].imshow(img,cmap='gray')
    axes[0,0].set_title("Original")
    axes[0,0].axis('off')

    axes[0,1].imshow(exact,cmap='gray')
    axes[0,1].set_title(exact_title)
    axes[0,1].axis('off')

    axes[1,0].imshow(approx,cmap='gray')
    axes[1,0].set_title(approx_title)
    axes[1,0].axis('off')

    im = axes[1,1].imshow(abs_error,cmap='hot')
    axes[1,1].set_title("Absolute Error Map")
    axes[1,1].axis('off')

    fig.colorbar(im, ax=axes[1,1])
    ensure_output_dir(COMBINED_OUTPUT)
    plt.savefig(COMBINED_OUTPUT,dpi=200)
    plt.show()

if __name__ == "__main__":