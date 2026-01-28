#this code is for EAL1 (AFA2) for 4,5,6,7, and 8 bit approximation for evaluation metrices 

N_BITS = 12
MAX_OUT = (1 << (N_BITS + 1)) - 1   # 13-bit max output = 8191


# ----------------------------------------------------------
# Exact ripple carry formula
# ----------------------------------------------------------
def exact_carry(Ai, Bi, Cin):
    return (Ai & Bi) | ((Ai ^ Bi) & Cin)


# ----------------------------------------------------------
# AFA2 Approximate Carry  (Cout = Cin)
# ----------------------------------------------------------
def carry_AFA2(Cin):
    return Cin     # ignores A and B completely!


# ----------------------------------------------------------
# Hybrid Approximate Adder using AFA2
# approx_bits = number of LSBs using AFA2 logic
# ----------------------------------------------------------
def approx_adder_AFA2(a, b, approx_bits):

    carry = 0
    result = 0

    # ---- LOWER BITS = AFA2 approximation ----
    for i in range(approx_bits):
        Ai = (a >> i) & 1
        Bi = (b >> i) & 1

        Si = Ai ^ Bi ^ carry
        carry = carry_AFA2(carry)     # AFA2 uses Cout = Cin

        result |= (Si << i)

    # ---- UPPER BITS = exact ripple ----
    for i in range(approx_bits, N_BITS):
        Ai = (a >> i) & 1
        Bi = (b >> i) & 1

        Si = Ai ^ Bi ^ carry
        carry = exact_carry(Ai, Bi, carry)

        result |= (Si << i)

    # Final carry-out (bit 12)
    result |= (carry << N_BITS)

    return result


# ----------------------------------------------------------
# Exact 12-bit addition
# ----------------------------------------------------------
def exact_adder(a, b):
    return a + b


# ----------------------------------------------------------
# Evaluate error for a given approximation size
# ----------------------------------------------------------
def evaluate_AFA2(approx_bits):

    total_err = 0
    err_count = 0
    N = (1 << (2 * N_BITS))          # 4096 × 4096 = 16,777,216

    for a in range(1 << N_BITS):
        for b in range(1 << N_BITS):

            exact = exact_adder(a, b)
            approx = approx_adder_AFA2(a, b, approx_bits)

            err = abs(exact - approx)
            total_err += err

            if err != 0:
                err_count += 1

    MED = total_err / N
    NMED = MED / MAX_OUT
    ACC = 1 - (err_count / N)

    return {
        "APPROX_BITS": approx_bits,
        "MED": MED,
        "NMED": NMED,
        "ERROR_COUNT": err_count,
        "ACCURACY": ACC,
        "TOTAL_TESTED": N
    }


# ----------------------------------------------------------
# MAIN — Run for 4, 5, 6, 7, 8 bit approximate windows
# ----------------------------------------------------------
if __name__ == "__main__":

    print("\n===== Hybrid 12-bit Approximate Adder — AFA2 (Cout = Cin) =====\n")

    for bits in [4, 5, 6, 7, 8]:
        print(f"--- Evaluating AFA2 with {bits}-bit approximation ---")
        stats = evaluate_AFA2(bits)
        print(stats, "\n")