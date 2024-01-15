#include <stdio.h>
#include <curand_kernel.h>
#include <stdlib.h>

const int NUM_PASSWORDS = 1024;
const int blockSize = 1024; // Max threads per block (depends on your GPU's capability)
const int gridSize = 1000 * (NUM_PASSWORDS + blockSize - 1) / blockSize; // 10x larger grid size
__constant__ char charset[] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+[]{}|;:,.<>?";

__global__ void generatePasswords(char *passwords, int charsetLength, int minLen, int maxLen) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= NUM_PASSWORDS * gridSize) return; // Guard to avoid out-of-bounds work

    curandState state;
    curand_init((unsigned long long)clock() + idx, 0, 0, &state);

    int passLen = minLen + curand(&state) % (maxLen - minLen + 1);

    for (int i = 0; i < passLen; ++i) {
        passwords[idx * (maxLen + 1) + i] = charset[curand(&state) % charsetLength];
    }
    passwords[idx * (maxLen + 1) + passLen] = '\0'; // Null-terminate the string
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("Usage: %s <min_length> <max_length>\n", argv[0]);
        return 1;
    }

    int minLen = atoi(argv[1]);
    int maxLen = atoi(argv[2]);

    if (minLen > maxLen || minLen < 1 || maxLen < 1) {
        printf("Invalid length parameters.\n");
        return 1;
    }

    char *d_passwords;
    char *h_passwords = (char *)malloc(NUM_PASSWORDS * gridSize * (maxLen + 1) * sizeof(char));

    cudaMalloc(&d_passwords, NUM_PASSWORDS * gridSize * (maxLen + 1) * sizeof(char));

    while (true) {  // Repeat the generation process indefinitely
        generatePasswords<<<gridSize, blockSize>>>(d_passwords, sizeof(charset) - 1, minLen, maxLen);
        cudaDeviceSynchronize();

        cudaMemcpy(h_passwords, d_passwords, NUM_PASSWORDS * gridSize * (maxLen + 1) * sizeof(char), cudaMemcpyDeviceToHost);

        for (int i = 0; i < NUM_PASSWORDS * gridSize; ++i) {
            printf("%s\n", h_passwords + i * (maxLen + 1));
        }

        // Optional: Add a delay if needed
        // sleep(1);
    }

    // Cleanup (unreachable in this version of the code)
    cudaFree(d_passwords);
    free(h_passwords);

    return 0;
}
