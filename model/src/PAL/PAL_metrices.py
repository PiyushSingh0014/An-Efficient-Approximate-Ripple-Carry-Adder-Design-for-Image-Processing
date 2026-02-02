#this is for evaluation matrices for PAL logic 

import time

N_BITS = 12
MAX_OUT = (1 << (N_BITS + 1)) - 1   
# Exact ripple carry formula

def exact_carry(Ai, Bi, Cin):
    return (Ai & Bi) | ((Ai ^ Bi) & Cin)
# From your uploaded files: Cout = A AND B

def carry_case2(Ai, Bi):
    return Ai & Bi

def approx_adder_case2(a, b, approx_bits):

    carry = 0
    result = 0
    for i in range(approx_bits):
        Ai = (a >> i) & 1
        Bi = (b >> i) & 1
        Si = Ai ^ Bi ^ carry
        carry = carry_case2(Ai, Bi)

        result |= (Si << i)
    for i in range(approx_bits, N_BITS):
        Ai = (a >> i) & 1
        Bi = (b >> i) & 1

        Si = Ai ^ Bi ^ carry
        carry = exact_carry(Ai, Bi, carry)

        result |= (Si << i)
    result |= (carry << N_BITS)

    return result

def exact_adder(a, b):
    return a + b

def evaluate_hybrid_case2(approx_bits):

    total_err = 0
    err_count = 0
    N = (1 << (2 * N_BITS))          

    for a in range(1 << N_BITS):
        for b in range(1 << N_BITS):

            exact = exact_adder(a, b)
            approx = approx_adder_case2(a, b, approx_bits)

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


if __name__ == "__main__":

    print("\n===== Hybrid 12-bit Approximate Adder — Case-2 (Cout=A.B) =====\n")
    print(f"Total combinations per case: {1 << (2*N_BITS):,} pairs\n")

    for bits in [4, 5, 6, 7, 8]:
        start_time = time.time()
        print(f"--- Evaluating Case-2 with {bits}-bit approximation ---")
        
        stats = evaluate_hybrid_case2(bits)
        
        elapsed = time.time() - start_time
        print(f"Results (took {elapsed:.2f}s):")
        print(stats)
        print("-" * 60 + "\n")