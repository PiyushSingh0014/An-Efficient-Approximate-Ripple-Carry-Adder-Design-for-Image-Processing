# this is for evaluaiton metrices for EAL4 logic 

N_BITS = 12
MAX_OUT = (1 << (N_BITS + 1)) - 1  

# Exact ripple carry formula (per-bit Cout)

def exact_carry(Ai, Bi, Cin):
    return (Ai & Bi) | ((Ai ^ Bi) & Cin)


# Type-D OR-based approximate adder for given K
# - bits 0..K-2 : S = A | B  (no carry)
# - bit K-1     : S = A | B  ; Cout = A & B
# - bits K..N-1 : exact ripple using Cout as Cin
# - final carry placed at bit N_BITS

def approx_adder_or(a, b, K):
    carry = 0
    result = 0

    #  LOWER OR PART (bits 0 .. K-2) 
    for i in range(0, max(0, K - 1)):
        Ai = (a >> i) & 1
        Bi = (b >> i) & 1
        Si = Ai | Bi
        result |= (Si << i)

    #  MS approximate bit (bit K-1): OR sum, AND carry 
    if K > 0:
        i = K - 1
        Ai = (a >> i) & 1
        Bi = (b >> i) & 1
        Si = Ai | Bi
        carry = Ai & Bi
        result |= (Si << i)

    #  UPPER EXACT RIPPLE (bits K .. N_BITS-1) 
    for i in range(K, N_BITS):
        Ai = (a >> i) & 1
        Bi = (b >> i) & 1
        Si = Ai ^ Bi ^ carry
        carry = exact_carry(Ai, Bi, carry)
        result |= (Si << i)

    # final carry-out at bit N_BITS
    result |= (carry << N_BITS)
    return result


# Exact 12-bit addition (reference)

def exact_adder(a, b):
    return a + b


def evaluate_case_or(K):
    total_err = 0
    err_count = 0
    N = (1 << (2 * N_BITS))  

    for a in range(1 << N_BITS):
        for b in range(1 << N_BITS):
            exact = exact_adder(a, b)
            approx = approx_adder_or(a, b, K)
            err = abs(exact - approx)
            total_err += err
            if err != 0:
                err_count += 1

    MED = total_err / N
    NMED = MED / MAX_OUT
    ACC = 1 - (err_count / N)

    return {
        "METHOD": "OR-BASED",
        "K_APPROX_BITS": K,
        "MED": MED,
        "NMED": NMED,
        "ERROR_COUNT": err_count,
        "ACCURACY": ACC,
        "TOTAL_TESTED": N
    }


if __name__ == "__main__":
    Ks = [4, 5, 6, 7, 8]
    print("\n===== OR-based Hybrid 12-bit Approximate Adder — Exhaustive Evaluation =====\n")
    for K in Ks:
        print(f"Running exhaustive evaluation for K = {K} approximate bits ...")
        stats = evaluate_case_or(K)
        print(stats)
        print()