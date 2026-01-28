#this is for evaluation metrices for EAL3 logic 

N_BITS = 12
MAX_OUT = (1 << (N_BITS + 1)) - 1  # 13-bit max output = 8191

# ----------------------------------------------
# Exact ripple carry formula (per-bit Cout)
# ----------------------------------------------
def exact_carry(Ai, Bi, Cin):
    return (Ai & Bi) | ((Ai ^ Bi) & Cin)

# ----------------------------------------------
# Exact 12-bit addition (reference)
# ----------------------------------------------
def exact_adder(a, b):
    return a + b

# ----------------------------------------------
# LXOA approximate adder (generic for any K)
# - Bits 0..K-2: S = A | B  (no carry)
# - Bit K-1    : S = A ^ B ; Cout = A & B
# - Bits K..N_BITS-1: exact ripple (use Cout as Cin)
# - Final carry placed at bit N_BITS
# ----------------------------------------------
def approx_adder_lxoa(a, b, K):
    carry = 0
    result = 0

    # ---- LOWER APPROX (bits 0 .. K-2) ----
    # If K <= 1, this loop does nothing
    for i in range(0, max(0, K - 1)):
        Ai = (a >> i) & 1
        Bi = (b >> i) & 1
        Si = Ai | Bi              # OR-approx
        # no carry update here (carry remains whatever it was, but for LXOA lower region carry is not used)
        result |= (Si << i)

    # ---- MOST-SIGNIFICANT APPROX BIT (bit K-1) ----
    if K > 0:
        i = K - 1
        Ai = (a >> i) & 1
        Bi = (b >> i) & 1
        Si = Ai ^ Bi              # XOR sum (half-adder)
        carry = Ai & Bi          # AND as carry-out -> becomes Cin for exact part
        result |= (Si << i)

    # ---- UPPER EXACT RIPPLE PART (bits K .. N_BITS-1) ----
    for i in range(K, N_BITS):
        Ai = (a >> i) & 1
        Bi = (b >> i) & 1
        Si = Ai ^ Bi ^ carry
        carry = exact_carry(Ai, Bi, carry)
        result |= (Si << i)

    # ---- final carry-out (bit N_BITS) ----
    result |= (carry << N_BITS)

    return result

# ----------------------------------------------
# Evaluate one K (exhaustive)
# Returns dictionary with statistics (same keys as before)
# ----------------------------------------------
def evaluate_case_lxoa(K):
    total_err = 0
    err_count = 0
    N = (1 << (2 * N_BITS))  # total pairs

    for a in range(1 << N_BITS):
        for b in range(1 << N_BITS):
            exact = exact_adder(a, b)
            approx = approx_adder_lxoa(a, b, K)
            err = abs(exact - approx)
            total_err += err
            if err != 0:
                err_count += 1

    MED = total_err / N
    NMED = MED / MAX_OUT
    ACC = 1 - (err_count / N)

    return {
        "METHOD": "LXOA",
        "K_APPROX_BITS": K,
        "MED": MED,
        "NMED": NMED,
        "ERROR_COUNT": err_count,
        "ACCURACY": ACC,
        "TOTAL_TESTED": N
    }

# ----------------------------------------------
# MAIN: run evaluations for K = 4..8 and print results
# ----------------------------------------------
if __name__ == "__main__":
    Ks = [4, 5, 6, 7, 8]

    print("\n===== LXOA Hybrid 12-bit Approximate Adder — Exhaustive Evaluation =====\n")
    for K in Ks:
        print(f"Running exhaustive evaluation for K = {K} approximate bits ...")
        stats = evaluate_case_lxoa(K)
        print(stats)
        print()