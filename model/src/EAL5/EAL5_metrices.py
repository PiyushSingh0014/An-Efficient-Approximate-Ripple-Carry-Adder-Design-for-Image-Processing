#this is for evaluation metrices for EAL5 logic 

N_BITS = 12
MAX_OUT = (1 << (N_BITS + 1)) - 1  


# Exact ripple carry formula (per-bit Cout)

def exact_carry(Ai, Bi, Cin):
    return (Ai & Bi) | ((Ai ^ Bi) & Cin)


# Sum = AB' + A'Cin + B Cin
# Cout = AB + A Cin

def approx_adder_custom(a, b, K):
    carry = 0
    result = 0

    #  LOWER APPROX PART (bits 0 .. K-1) 
    for i in range(0, min(K, N_BITS)):
        Ai = (a >> i) & 1
        Bi = (b >> i) & 1
        Cin = carry

        # SUM = A B' + A' Cin + B Cin
        Si = (Ai & (not Bi)) or ((not Ai) & Cin) or (Bi & Cin)
        Si = 1 if Si else 0

        # COUT = AB + A Cin
        Cout = (Ai & Bi) or (Ai & Cin)
        Cout = 1 if Cout else 0

        result |= (Si << i)
        carry = Cout

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


# Exact N-bit addition (reference)

def exact_adder(a, b):
    return a + b


def evaluate_case_custom(K):
    total_err = 0
    err_count = 0
    N = (1 << (2 * N_BITS))  

    for a in range(1 << N_BITS):
        for b in range(1 << N_BITS):
            exact = exact_adder(a, b)
            approx = approx_adder_custom(a, b, K)
            err = abs(exact - approx)
            total_err += err
            if err != 0:
                err_count += 1

    MED = total_err / N
    NMED = MED / MAX_OUT
    ACC = 1 - (err_count / N)

    return {
        "METHOD": "USER_CUSTOM_APPROX",
        "K_APPROX_BITS": K,
        "MED": MED,
        "NMED": NMED,
        "ERROR_COUNT": err_count,
        "ACCURACY": ACC,
        "TOTAL_TESTED": N
    }
if __name__ == "__main__":
    Ks = [4, 5, 6, 7, 8]
    print("\n===== Custom Hybrid 12-bit Approximate Adder — Exhaustive Evaluation =====\n")
    for K in Ks:
        print(f"Running exhaustive evaluation for K = {K} approximate bits ...")
        stats = evaluate_case_custom(K)
        print(stats)
        print()