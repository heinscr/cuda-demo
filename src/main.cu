#include <iostream>
#include <vector>
#include "vector_add.h"

__global__ void vecAdd(const float* A, const float* B, float* C, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) C[i] = A[i] + B[i];
}

void host_vector_add(const std::vector<float>& A, const std::vector<float>& B, std::vector<float>& C) {
    int N = (int)A.size();
    float *d_A = nullptr, *d_B = nullptr, *d_C = nullptr;
    cudaMalloc(&d_A, N * sizeof(float));
    cudaMalloc(&d_B, N * sizeof(float));
    cudaMalloc(&d_C, N * sizeof(float));
    cudaMemcpy(d_A, A.data(), N * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, B.data(), N * sizeof(float), cudaMemcpyHostToDevice);

    int blockSize = 256;
    int gridSize = (N + blockSize - 1) / blockSize;
    vecAdd<<<gridSize, blockSize>>>(d_A, d_B, d_C, N);
    cudaDeviceSynchronize();

    cudaMemcpy(C.data(), d_C, N * sizeof(float), cudaMemcpyDeviceToHost);

    cudaFree(d_A); cudaFree(d_B); cudaFree(d_C);
}

int main(int argc, char** argv) {
    int N = 1 << 20; // 1M elements
    std::vector<float> A(N, 1.0f), B(N, 2.0f), C(N, 0.0f);
    host_vector_add(A, B, C);

    // Compute errors and show a small sample of values
    double max_abs_err = 0.0;
    int samples = 10;
    std::cout << "Sample results (index: A + B = expected -> actual):" << std::endl;
    for (int i = 0; i < samples; ++i) {
        float expected = A[i] + B[i];
        float actual = C[i];
        double err = std::abs((double)actual - (double)expected);
        if (err > max_abs_err) max_abs_err = err;
        std::cout << i << ": " << A[i] << " + " << B[i] << " = " << expected
                  << " -> " << actual << " (err=" << err << ")" << std::endl;
    }

    // Check overall correctness (allowing tiny fp error)
    for (int i = samples; i < N; ++i) {
        double err = std::abs((double)C[i] - ((double)A[i] + (double)B[i]));
        if (err > max_abs_err) max_abs_err = err;
    }

    const double tol = 1e-6;
    bool ok = (max_abs_err <= tol);
    std::cout << "Max absolute error: " << max_abs_err << std::endl;
    std::cout << "Result: " << (ok ? "PASS" : "FAIL") << std::endl;
    return ok ? 0 : 1;
}
