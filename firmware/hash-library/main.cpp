#include "sha256.h"

static volatile uint32_t* const output =
    (volatile uint32_t*)0x00004000u;
static volatile uint32_t* const done =
    (volatile uint32_t*)0x00004020u;
static volatile uint32_t* const started =
    (volatile uint32_t*)0x00004024u;

int main()
{
    //static const unsigned char message[] = {'a', 'b', 'c'};
    unsigned char digest[SHA256::HashBytes];

    *started = 1;

    SHA256 sha;
    //commenting out, to try an empty string for now
   // sha.add(message, sizeof(message));
    sha.getHash(digest);
    //convert 32 bytes to 8 words
    for (size_t i = 0; i < SHA256::HashBytes / 4; ++i) {
        size_t j = i * 4;
        output[i] =
            ((uint32_t)digest[j]     << 24) |
            ((uint32_t)digest[j + 1] << 16) |
            ((uint32_t)digest[j + 2] << 8)  |
             (uint32_t)digest[j + 3];
    }

    *done = 1;

    while (1) {
    }
}
