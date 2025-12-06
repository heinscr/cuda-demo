CUDA C++ demo project

This repository provides a minimal, professional layout to demo a simple CUDA vector-add example.

Quick start

1. Make sure `nvcc` is available in your PATH or set `CUDA_HOME` to your CUDA installation root.

2. Build (release):

Quick start (CMake)

1. Verify CUDA is installed (`nvcc` or `CUDAToolkit` available).

2. Create a build directory and configure with CMake:

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
```

3. Build the example:

```bash
cmake --build build --config Release -j
```

4. Run the example:

```bash
./build/bin/vector_add
```

Notes

- The project uses modern CMake and `find_package(CUDAToolkit)` to locate CUDA.
- To target specific GPU architectures, set `CMAKE_CUDA_ARCHITECTURES` when configuring, e.g. `-DCMAKE_CUDA_ARCHITECTURES=50;60;70`.
- If CMake cannot find CUDA, ensure the CUDA Toolkit is installed and `nvcc` is available, or provide `-DCUDAToolkit_ROOT=/path/to/cuda`.