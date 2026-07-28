# Memory map
0x0000_0000 - 0x0000_FFFF   64 KiB AXI RAM
0x1000_0000 - 0x1000_00FF   SHA-256 peripheral
# SHA register table
0x00 CTRL
0x04 STATUS
0x08-0x44 BLOCK0-BLOCK15
0x80-0x9C DIGEST0-DIGEST7

# Block Word Ordering

The SHA-256 accelerator accepts **one 512-bit message block** as input. The block is divided into **16 memory-mapped 32-bit registers** (`BLOCK0` through `BLOCK15`).

Internally, the registers are packed into the 512-bit input block as shown below:

| Register | Bits of 512-bit Block |
|----------|----------------------:|
| `BLOCK0`  | `[511:480]` |
| `BLOCK1`  | `[479:448]` |
| `BLOCK2`  | `[447:416]` |
| `BLOCK3`  | `[415:384]` |
| `BLOCK4`  | `[383:352]` |
| `BLOCK5`  | `[351:320]` |
| `BLOCK6`  | `[319:288]` |
| `BLOCK7`  | `[287:256]` |
| `BLOCK8`  | `[255:224]` |
| `BLOCK9`  | `[223:192]` |
| `BLOCK10` | `[191:160]` |
| `BLOCK11` | `[159:128]` |
| `BLOCK12` | `[127:96]` |
| `BLOCK13` | `[95:64]` |
| `BLOCK14` | `[63:32]` |
| `BLOCK15` | `[31:0]` |

This ordering follows the SHA-256 specification, where each 32-bit word is interpreted in **big-endian** order.

---

# Example: SHA-256 of the Empty String

The empty string (`""`) has a length of zero bytes. So the  512-bit message block, after padding, is:

```text
80000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
```

The software writes the following values to the SHA block registers:

| Register | Value |
|----------|-----------:|
| `BLOCK0`  | `0x80000000` |
| `BLOCK1`  | `0x00000000` |
| `BLOCK2`  | `0x00000000` |
| `BLOCK3`  | `0x00000000` |
| `BLOCK4`  | `0x00000000` |
| `BLOCK5`  | `0x00000000` |
| `BLOCK6`  | `0x00000000` |
| `BLOCK7`  | `0x00000000` |
| `BLOCK8`  | `0x00000000` |
| `BLOCK9`  | `0x00000000` |
| `BLOCK10` | `0x00000000` |
| `BLOCK11` | `0x00000000` |
| `BLOCK12` | `0x00000000` |
| `BLOCK13` | `0x00000000` |
| `BLOCK14` | `0x00000000` |
| `BLOCK15` | `0x00000000` |

Once all sixteen block registers have been written, software starts the accelerator by writing:

```text
CTRL = 0x00000001
```

The accelerator computes the following SHA-256 digest:

```text
e3b0c442
98fc1c14
9afbf4c8
996fb924
27ae41e4
649b934c
a495991b
7852b855
```

---

# Example: SHA-256 of `"abc"`

The ASCII string `"abc"` is padded into the following 512-bit block:

```text
61626380
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000018
```

The corresponding register values are:

| Register | Value |
|----------|-----------:|
| `BLOCK0`  | `0x61626380` |
| `BLOCK1`  | `0x00000000` |
| `BLOCK2`  | `0x00000000` |
| `BLOCK3`  | `0x00000000` |
| `BLOCK4`  | `0x00000000` |
| `BLOCK5`  | `0x00000000` |
| `BLOCK6`  | `0x00000000` |
| `BLOCK7`  | `0x00000000` |
| `BLOCK8`  | `0x00000000` |
| `BLOCK9`  | `0x00000000` |
| `BLOCK10` | `0x00000000` |
| `BLOCK11` | `0x00000000` |
| `BLOCK12` | `0x00000000` |
| `BLOCK13` | `0x00000000` |
| `BLOCK14` | `0x00000000` |
| `BLOCK15` | `0x00000018` |

Expected SHA-256 digest:

```text
ba7816bf
8f01cfea
414140de
5dae2223
b00361a3
96177a9c
b410ff61
f20015ad
```
