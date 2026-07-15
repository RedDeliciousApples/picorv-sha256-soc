#define SHA_BASE      0x10000000u

#define SHA_CTRL      (*(volatile unsigned int *)(SHA_BASE + 0x00u))
#define SHA_STATUS    (*(volatile unsigned int *)(SHA_BASE + 0x04u))

#define SHA_BLOCK0    (*(volatile unsigned int *)(SHA_BASE + 0x08u))
#define SHA_BLOCK1    (*(volatile unsigned int *)(SHA_BASE + 0x0Cu))
#define SHA_BLOCK2    (*(volatile unsigned int *)(SHA_BASE + 0x10u))
#define SHA_BLOCK3    (*(volatile unsigned int *)(SHA_BASE + 0x14u))
#define SHA_BLOCK4    (*(volatile unsigned int *)(SHA_BASE + 0x18u))
#define SHA_BLOCK5    (*(volatile unsigned int *)(SHA_BASE + 0x1Cu))
#define SHA_BLOCK6    (*(volatile unsigned int *)(SHA_BASE + 0x20u))
#define SHA_BLOCK7    (*(volatile unsigned int *)(SHA_BASE + 0x24u))
#define SHA_BLOCK8    (*(volatile unsigned int *)(SHA_BASE + 0x28u))
#define SHA_BLOCK9    (*(volatile unsigned int *)(SHA_BASE + 0x2Cu))
#define SHA_BLOCK10   (*(volatile unsigned int *)(SHA_BASE + 0x30u))
#define SHA_BLOCK11   (*(volatile unsigned int *)(SHA_BASE + 0x34u))
#define SHA_BLOCK12   (*(volatile unsigned int *)(SHA_BASE + 0x38u))
#define SHA_BLOCK13   (*(volatile unsigned int *)(SHA_BASE + 0x3Cu))
#define SHA_BLOCK14   (*(volatile unsigned int *)(SHA_BASE + 0x40u))
#define SHA_BLOCK15   (*(volatile unsigned int *)(SHA_BASE + 0x44u))

#define SHA_DIGEST0   (*(volatile unsigned int *)(SHA_BASE + 0x80u))
#define SHA_DIGEST1   (*(volatile unsigned int *)(SHA_BASE + 0x84u))
#define SHA_DIGEST2   (*(volatile unsigned int *)(SHA_BASE + 0x88u))
#define SHA_DIGEST3   (*(volatile unsigned int *)(SHA_BASE + 0x8Cu))
#define SHA_DIGEST4   (*(volatile unsigned int *)(SHA_BASE + 0x90u))
#define SHA_DIGEST5   (*(volatile unsigned int *)(SHA_BASE + 0x94u))
#define SHA_DIGEST6   (*(volatile unsigned int *)(SHA_BASE + 0x98u))
#define SHA_DIGEST7   (*(volatile unsigned int *)(SHA_BASE + 0x9Cu))

#define OUT0          (*(volatile unsigned int *)0x00000100u)
#define OUT1          (*(volatile unsigned int *)0x00000104u)
#define OUT2          (*(volatile unsigned int *)0x00000108u)
#define OUT3          (*(volatile unsigned int *)0x0000010Cu)
#define OUT4          (*(volatile unsigned int *)0x00000110u)
#define OUT5          (*(volatile unsigned int *)0x00000114u)
#define OUT6          (*(volatile unsigned int *)0x00000118u)
#define OUT7          (*(volatile unsigned int *)0x0000011Cu)

void main(void)
{
    // SHA-256 padded block for empty string.
    // Message length = 0 bits.
    SHA_BLOCK0  = 0x80000000u;
    SHA_BLOCK1  = 0x00000000u;
    SHA_BLOCK2  = 0x00000000u;
    SHA_BLOCK3  = 0x00000000u;
    SHA_BLOCK4  = 0x00000000u;
    SHA_BLOCK5  = 0x00000000u;
    SHA_BLOCK6  = 0x00000000u;
    SHA_BLOCK7  = 0x00000000u;
    SHA_BLOCK8  = 0x00000000u;
    SHA_BLOCK9  = 0x00000000u;
    SHA_BLOCK10 = 0x00000000u;
    SHA_BLOCK11 = 0x00000000u;
    SHA_BLOCK12 = 0x00000000u;
    SHA_BLOCK13 = 0x00000000u;
    SHA_BLOCK14 = 0x00000000u;
    SHA_BLOCK15 = 0x00000000u;

    // Start SHA.
    SHA_CTRL = 0x00000001u;

    // STATUS bit 2 = done.
    while ((SHA_STATUS & 0x00000004u) == 0u) {
    }

    // Copy digest into RAM so the testbench can check it.
    OUT0 = SHA_DIGEST0;
    OUT1 = SHA_DIGEST1;
    OUT2 = SHA_DIGEST2;
    OUT3 = SHA_DIGEST3;
    OUT4 = SHA_DIGEST4;
    OUT5 = SHA_DIGEST5;
    OUT6 = SHA_DIGEST6;
    OUT7 = SHA_DIGEST7;

    while (1) {
    }
}
