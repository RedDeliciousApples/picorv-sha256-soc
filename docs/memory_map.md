# Memory map
| Memory Region | Purpose |
|----------|----------------------:|
|0x0000_0000 - 0x0000_FFFF |  64 KiB AXI RAM |
|0x1000_0000 - 0x1000_00FF |  SHA-256 peripheral |
# SHA register table
| Register | Purpose |
|----------|----------------------:|
|0x00 | CTRL, where CTRL[0] = start and CTRL[1] = continue (0 = new message, 1 = chain onto the previous digest) |
|0x04  | STATUS |
|0x08-0x44  | BLOCK0-BLOCK15 |
|0x80-0x9C  | DIGEST0-DIGEST7 |

Remember that the registers require AXI-Lite `WSTRB`. You must set the strobe bit to update that specific register.

# Block Word Ordering

The SHA-256 accelerator divides the messages into 512-bit message blocks as input, and it's then divided into 16 registers (`BLOCK0` through `BLOCK15`).

Internally, the registers are organized in the 512-bit block like this:

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

Each 32-bit word uses big-endian order.
