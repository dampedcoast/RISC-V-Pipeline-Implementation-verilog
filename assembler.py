import re

instruction_set = {
    "addw":  {"type": "R", "opcode": "0111011", "funct3": "000", "funct7": "0000000"},
    "addiw": {"type": "I", "opcode": "0011011", "funct3": "000"},
    "and":   {"type": "R", "opcode": "0110011", "funct3": "111", "funct7": "0000000"},
    "andi":  {"type": "I", "opcode": "0010011", "funct3": "111"},
    "bge":   {"type": "SB", "opcode": "1100011", "funct3": "101"},
    "bne":   {"type": "SB", "opcode": "1100011", "funct3": "001"},
    "jal":   {"type": "UJ", "opcode": "1101111"},
    "jalr":  {"type": "I", "opcode": "1100111", "funct3": "000"},
    "lh":    {"type": "I", "opcode": "0000011", "funct3": "001"},
    "lui":   {"type": "U", "opcode": "0110111"},
    "lw":    {"type": "I", "opcode": "0000011", "funct3": "010"},
    "xor":   {"type": "R", "opcode": "0110011", "funct3": "100", "funct7": "0000000"},
    "or":    {"type": "R", "opcode": "0110011", "funct3": "110", "funct7": "0000000"},
    "ori":   {"type": "I", "opcode": "0010011", "funct3": "110"},
    "sltu":  {"type": "R", "opcode": "0110011", "funct3": "011", "funct7": "0000000"},
    "slli":  {"type": "I", "opcode": "0010011", "funct3": "001", "funct7": "0000000", "has_shift_flag": True},
    "srli":  {"type": "I", "opcode": "0010011", "funct3": "101", "funct7": "0000000", "has_shift_flag": True},
    "srai":  {"type": "I", "opcode": "0010011", "funct3": "101", "funct7": "0100000", "has_shift_flag": True},
    "srl":   {"type": "R", "opcode": "0110011", "funct3": "101", "funct7": "0000000"},
    "sra":   {"type": "R", "opcode": "0110011", "funct3": "101", "funct7": "0100000"},
    "sb":    {"type": "S", "opcode": "0100011", "funct3": "000"},
    "sw":    {"type": "S", "opcode": "0100011", "funct3": "010"},
    "sub":   {"type": "R", "opcode": "0110011", "funct3": "000", "funct7": "0100000"},

}

def convert_to_integer(value):
    if isinstance(value, str):
        return int(value, 0)
    return int(value)

def register_to_binary(register_name):
    if register_name.startswith('x'):
        register_number = int(register_name[1:])
    else:
        register_number = int(register_name)
    
    if not (0 <= register_number <= 31):
        raise ValueError(f"Register out of range: {register_name}")
    return f"{register_number:05b}"

def immediate_to_binary(value, bit_width):
    integer_value = convert_to_integer(value)
    integer_value &= (1 << bit_width) - 1
    return f"{integer_value:0{bit_width}b}"

def generate_binary_code(mnemonic, operand_list):
    instruction_info = instruction_set[mnemonic]
    instruction_type = instruction_info["type"]

    if instruction_type == "R":
        destination, source1, source2 = operand_list
        return (
            instruction_info["funct7"] + 
            register_to_binary(source2) + 
            register_to_binary(source1) + 
            instruction_info["funct3"] + 
            register_to_binary(destination) + 
            instruction_info["opcode"]
        )

    elif instruction_type == "I":
        destination, source1, immediate = operand_list
        
        if instruction_info.get("has_shift_flag", False):
            shift_amount = immediate_to_binary(immediate, 5)
            binary_immediate = instruction_info["funct7"] + shift_amount
        else:
            binary_immediate = immediate_to_binary(immediate, 12)

        return (
            binary_immediate + 
            register_to_binary(source1) + 
            instruction_info["funct3"] + 
            register_to_binary(destination) + 
            instruction_info["opcode"]
        )

    elif instruction_type == "S":
        source2, source1, immediate = operand_list
        immediate_value = convert_to_integer(immediate) & 0xfff
        immediate_high = (immediate_value >> 5) & 0x7f
        immediate_low = immediate_value & 0x1f
        
        return (
            f"{immediate_high:07b}" + 
            register_to_binary(source2) + 
            register_to_binary(source1) + 
            instruction_info["funct3"] + 
            f"{immediate_low:05b}" + 
            instruction_info["opcode"]
        )

    elif instruction_type == "SB":
        source1, source2, immediate = operand_list
        immediate_value = convert_to_integer(immediate) & 0x1fff
        bit_12 = (immediate_value >> 12) & 1
        bits_10_to_5 = (immediate_value >> 5) & 0x3F
        bits_4_to_1 = (immediate_value >> 1) & 0xF
        bit_11 = (immediate_value >> 11) & 1

        return (
            f"{bit_12:b}{bits_10_to_5:06b}" +
            register_to_binary(source2) + 
            register_to_binary(source1) +
            instruction_info["funct3"] +
            f"{bits_4_to_1:04b}{bit_11:b}" +
            instruction_info["opcode"]
        )

    elif instruction_type == "U":
        destination, immediate = operand_list
        immediate_value = convert_to_integer(immediate)
        # For LUI, the immediate is already the upper 20 bits value
        # No need to shift right - just mask to 20 bits
        immediate_high = immediate_value & 0xFFFFF
        return f"{immediate_high:020b}" + register_to_binary(destination) + instruction_info["opcode"]

    elif instruction_type == "UJ":
        destination, immediate = operand_list
        immediate_value = convert_to_integer(immediate) & 0x1FFFFF
        bit_20 = (immediate_value >> 20) & 1
        bits_10_to_1 = (immediate_value >> 1) & 0x3FF
        bit_11 = (immediate_value >> 11) & 1
        bits_19_to_12 = (immediate_value >> 12) & 0xFF

        return (
            f"{bit_20:b}{bits_10_to_1:010b}{bit_11:b}{bits_19_to_12:08b}" +
            register_to_binary(destination) +
            instruction_info["opcode"]
        )

    else:
        raise ValueError(f"Unknown type: {instruction_type}")

def parse_line_operands(line_text, instruction_type):
    tokens = re.split(r"[,\s()]+", line_text.strip())
    tokens = [token for token in tokens if token]

    if instruction_type == "R":
        return tokens[1], tokens[2], tokens[3]

    elif instruction_type == "I":
        # Handle 'jalr x1, 20(x2)' format
        if '(' in line_text:
            return tokens[1], tokens[3], tokens[2]
        # Handle 'jalr x1, x2, 20' or 'addiw x1, x2, 10' format
        return tokens[1], tokens[2], tokens[3]

    elif instruction_type == "S":
        return tokens[1], tokens[3], tokens[2]

    elif instruction_type == "SB":
        return tokens[1], tokens[2], tokens[3]

    elif instruction_type in ("U", "UJ"):
        return tokens[1], tokens[2]

    raise ValueError("Unknown instruction type")

def assemble(line_text):
    line_text = line_text.strip()
    if not line_text or line_text.startswith('#'):
        return None
    
    mnemonic = line_text.split()[0].lower()
    if mnemonic not in instruction_set:
        raise ValueError(f"Unknown instruction: {mnemonic}")

    operand_list = parse_line_operands(line_text, instruction_set[mnemonic]["type"])
    binary_string = generate_binary_code(mnemonic, operand_list)

    return f"{int(binary_string, 2):08x}"








tests1 = [
    "addw x1, x2, x3",
    "addiw x1, x2, 10",
    "and x5, x6, x7",
    "andi x5, x6, 12",
    "bge x1, x2, 8",
    "bne x1, x2, 16",
    "jal x1, 40",
    "jalr x1, x2, 20",
    "lw x1, 8(x2)",
    "lh x3, 4(x5)",
    "sw x1, 12(x2)",
    "sb x3, 5(x7)",
    "ori x1, x2, 7",
    "xor x1, x2, x3",
    "sltu x1, x2, x3",
    "slli x1, x2, 1",
    "srli x3, x4, 2",
    "srai x5, x6, 3",
    "sub x1, x2, x3",
    "lui x1, 0x10000",
]
tests2 = [
    # R-type group
    "and x1, x2, x3",
    "addw x1, x2, x3",
    "sub x1, x2, x3",
    "sltu x1, x2, x3",
    "xor x1, x2, x3",
    "srl x1, x2, x3",
    "sra x1, x2, x3",
    "or x1, x2, x3",

    # I-type group
    "slli x1, x2, 2",
    "ori x1, x2, 7",
    "lw x1, 3(x2)",
    "lh x1, 4(x2)",
    "addiw x1, x2, 1",
    "andi x1, x2, 0",
    "jalr x1, x2, 1",

    # U-type
    "lui x1, 0x38",

    # SB-type
    "bge x1, x2, 6",
    "bne x1, x2, 2",

    # UJ-type
    "jal x1, 70",

    # S-type
    "sb x1, 1(x2)",
    "sw x1, 3(x2)",
]


all_tests = tests1 + tests2


print("\n==================== ASSEMBLER TEST RESULTS ====================\n")

for t in all_tests:
    try:
        hex_value = assemble(t)
        print(f"{t:<30} → {hex_value}")
    except Exception as e:
        print(f"{t:<30} → ERROR: {e}")

print("\n============================ DONE ==============================\n")