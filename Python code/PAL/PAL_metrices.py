#this is for evaluation matrices for PAL logic 

import time

N_BITS = 12
MAX_OUT = (1 << (N_BITS + 1)) - 1   # 13-bit max output = 8191


# ----------------------------------------------------------
# Exact ripple carry formula
# ----------------------------------------------------------
def exact_carry(Ai, Bi, Cin):
    return (Ai & Bi) | ((Ai ^ Bi) & Cin)


# ----------------------------------------------------------
# CASE-2 Approximate Carry Formula
# From your uploaded files: Cout = A AND B
# ----------------------------------------------------------
def carry_case2(Ai, Bi):
    return Ai & Bi


# ----------------------------------------------------------
# Hybrid Approximate Adder
# approx_bits = number of LSBs using Case-2 logic
# ----------------------------------------------------------
def approx_adder_case2(a, b, approx_bits):

    carry = 0
    result = 0

    # ---- LOWER BITS = Approximate (Case-2) ----
    # Uses Cout = A & B. This ignores the previous carry 'Cin' 
    # for the generation of the *next* carry.
    for i in range(approx_bits):
        Ai = (a >> i) & 1
        Bi = (b >> i) & 1

        # Sum is always standard full adder sum
        Si = Ai ^ Bi ^ carry
        
        # New Carry depends ONLY on A and B (Case-2 Logic)
        carry = carry_case2(Ai, Bi)

        result |= (Si << i)

    # ---- UPPER BITS = Exact Ripple Carry ----
    # Standard adder logic for the remaining MSBs
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
# Exact 12-bit addition (Reference)
# ----------------------------------------------------------
def exact_adder(a, b):
    return a + b


# ----------------------------------------------------------
# Evaluate error for a given approximation size
# ----------------------------------------------------------
def evaluate_hybrid_case2(approx_bits):

    total_err = 0
    err_count = 0
    N = (1 << (2 * N_BITS))          # 4096 * 4096 = 16,777,216 pairs

    # Iterate through all possible input pairs
    for a in range(1 << N_BITS):
        for b in range(1 << N_BITS):

            exact = exact_adder(a, b)
            approx = approx_adder_case2(a, b, approx_bits)

            err = abs(exact - approx)
            total_err += err

            if err != 0:
                err_count += 1

    # Calculate Metrics
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
# MAIN — Run for 4, 5, 6, 7, and 8 bit approximate windows
# ----------------------------------------------------------
if __name__ == "__main__":

    print("\n===== Hybrid 12-bit Approximate Adder — Case-2 (Cout=A.B) =====\n")
    print(f"Total combinations per case: {1 << (2*N_BITS):,} pairs\n")

    # Loop through the requested bit widths
    for bits in [4, 5, 6, 7, 8]:
        start_time = time.time()
        print(f"--- Evaluating Case-2 with {bits}-bit approximation ---")
        
        stats = evaluate_hybrid_case2(bits)
        
        elapsed = time.time() - start_time
        print(f"Results (took {elapsed:.2f}s):")
        print(stats)
        print("-" * 60 + "\n")