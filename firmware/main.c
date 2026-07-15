volatile unsigned int *ram_test = (volatile unsigned int *)0x00000100;

void main(void)
{
    *ram_test = 0x12345678;

    while (1) {
    }
}
