import sys
import math

def parse_intel_hex(hex_filename):
    """
    Parse Intel HEX file into a dict: address -> byte.
    """
    memory = {}
    with open(hex_filename, "r") as f:
        for line in f:
            line = line.strip()
            if not line or not line.startswith(":"):
                continue
            byte_count = int(line[1:3], 16)
            addr = int(line[3:7], 16)
            record_type = int(line[7:9], 16)
            if record_type == 0x00:
                data_str = line[9:9 + byte_count * 2]
                for i in range(byte_count):
                    memory[addr + i] = int(data_str[i*2:(i+1)*2], 16)
            elif record_type == 0x01:  # End Of File
                break
            else:
                # skip other record types
                continue
    return memory

def build_contiguous(memory, fill_value=0):
    """
    Given a sparse memory dict, produce a contiguous sorted byte list.
    """
    if not memory:
        return []
    min_addr = min(memory.keys())
    max_addr = max(memory.keys())
    data = []
    for addr in range(min_addr, max_addr + 1):
        data.append(memory.get(addr, fill_value & 0xFF))
    return data, min_addr

def group_words(byte_data, word_bits):
    """
    Group bytes into words of width word_bits (must be multiple of 8 bits).
    Returns list of integers as words.
    """
    assert word_bits % 8 == 0
    bytes_per_word = word_bits // 8
    # Pad to multiple of bytes_per_word
    padding = (-len(byte_data)) % bytes_per_word
    byte_data.extend([0] * padding)
    words = []
    for i in range(0, len(byte_data), bytes_per_word):
        word = 0
        for j in range(bytes_per_word):
            word |= byte_data[i + j] << (8 * (bytes_per_word - j - 1))
        words.append(word)
    return words

def write_coe(words, coe_filename, radix=16):
    """
    Write .coe file, one value per line.
    """
    with open(coe_filename, "w") as f:
        f.write(f"memory_initialization_radix={radix};\n")
        f.write("memory_initialization_vector=\n")
        for i, w in enumerate(words):
            sep = ";" if i == len(words) - 1 else ","
            f.write(f"{w:0{math.ceil(radix/4)}X}{sep}\n")

def write_mem(words, mem_filename, word_bits):
    """
    Write .mem plain hex words (one per line).
    """
    with open(mem_filename, "w") as f:
        width_hex = word_bits // 4
        for w in words:
            f.write(f"{w:0{width_hex}X}\n")

def write_mif(words, mif_filename, word_bits):
    """
    Write .mif file (Quartus format).
    """
    depth = len(words)
    width = word_bits
    with open(mif_filename, "w") as f:
        f.write(f"WIDTH={width};\n")
        f.write(f"DEPTH={depth};\n\n")
        f.write("ADDRESS_RADIX=HEX;\n")
        f.write("DATA_RADIX=HEX;\n\n")
        f.write("CONTENT BEGIN\n")
        for addr, w in enumerate(words):
            f.write(f"    {addr:04X} : {w:0{width//4}X};\n")
        f.write("END;\n")

def hex_to_init(
    hex_filename,
    coe_filename=None,
    mem_filename=None,
    mif_filename=None,
    fill_value=0,
    word_bits=8
):
    if not (coe_filename or mem_filename or mif_filename):
        raise ValueError("Provide at least one output file.")

    memory = parse_intel_hex(hex_filename)
    byte_data, base_addr = build_contiguous(memory, fill_value)
    words = group_words(byte_data, word_bits)

    if coe_filename:
        write_coe(words, coe_filename, radix=word_bits)
    if mem_filename:
        write_mem(words, mem_filename, word_bits)
    if mif_filename:
        write_mif(words, mif_filename, word_bits)

if __name__ == "__main__":
    # Example usage (adjust paths and word_bits as needed):
    hex_to_init(
        mif_filename="./program1/out.mif",
        hex_filename="./program1/input.txt",
        coe_filename="./program1/4001_generate.coe",
        mem_filename="./program1/4001_generate.mem",
        fill_value=0x00,
        word_bits=8
    )
