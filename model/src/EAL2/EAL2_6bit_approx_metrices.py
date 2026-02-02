#this is for 6 bit approximation for evalauation metrices using EAL2 logic 
N_BITS = 12
MAX_OUT = (1 << (N_BITS + 1)) - 1   # 13-bit max output = 8191


def exact_carry(Ai, Bi, Cin):
    return (Ai & Bi) | ((Ai ^ Bi) & Cin)


#  carry formula (Cout = A·B
def carry_case2(Ai, Bi):
    return Ai & Bi


# Hybrid Approximate Adder (Lower 6 bits approx)
# Pattern:
#  - bits [1:0]  -> 2-AxB1: S0 = 1, S1 = A1 | B1 (no carry)
#  - bits [3:2]  -> 2-AxB1: S2 = 1, S3 = A3 | B3 (no carry)
#  - bits [5:4]  -> 2-AxB2: S4 = 1, S5 = A5 ^ B5, carry_out = A5 & B5
#  - bits [6..11] -> exact ripple starting from carry_out of 2-AxB2
def approx_adder_case2(a, b):

    carry = 0
    result = 0

    # ---- LOWER 2-BIT BLOCK: 2-AxB1 on bits [1:0] ----
    A0 = (a >> 0) & 1
    B0 = (b >> 0) & 1
    A1 = (a >> 1) & 1
    B1 = (b >> 1) & 1

    S0 = 1              
    S1 = A1 | B1       
    result |= (S0 << 0)
    result |= (S1 << 1)

    # ---- NEXT 2-BIT BLOCK: 2-AxB1 on bits [3:2] ----
    A2 = (a >> 2) & 1
    B2 = (b >> 2) & 1
    A3 = (a >> 3) & 1
    B3 = (b >> 3) & 1

    S2 = 1            
    S3 = A3 | B3       

    result |= (S2 << 2)
    result |= (S3 << 3)

    # ---- NEXT 2-BIT BLOCK (top of approx region): 2-AxB2 on bits [5:4] ----
    A4 = (a >> 4) & 1
    B4 = (b >> 4) & 1
    A5 = (a >> 5) & 1
    B5 = (b >> 5) & 1

    S4 = 1          
    S5 = A5 ^ B5        
    carry = A5 & B5     
    result |= (S4 << 4)
    result |= (S5 << 5)

    # ---- UPPER BITS (6–11) = exact ripple ----
    for i in range(6, N_BITS):   
        Ai = (a >> i) & 1
        Bi = (b >> i) & 1

        Si = Ai ^ Bi ^ carry
        carry = exact_carry(Ai, Bi, carry)

        result |= (Si << i)

    
    result |= (carry << N_BITS)

    return result


# Exact 12-bit addition
def exact_adder(a, b):
    return a + b

def evaluate_case2():

    total_err = 0
    err_count = 0
    N = (1 << (2 * N_BITS)) 

    for a in range(1 << N_BITS):
        for b in range(1 << N_BITS):

            exact = exact_adder(a, b)
            approx = approx_adder_case2(a, b)

            err = abs(exact - approx)
            total_err += err

            if err != 0:
                err_count += 1

    MED = total_err / N
    NMED = MED / MAX_OUT
    ACC = 1 - (err_count / N)

    return {
        "CASE": 2,
        "APPROX_BITS": 6,
        "MED": MED,
        "NMED": NMED,
        "ERROR_COUNT": err_count,
        "ACCURACY": ACC,
        "TOTAL_TESTED": N
    }


if __name__ == "__main__":
    print("\n===== Hybrid 12-bit Approximate Adder — CASE 2 (6-bit Approx: two 2-AxB1 + one 2-AxB2) =====\n")
    stats = evaluate_case2()
    print(stats)
    print()