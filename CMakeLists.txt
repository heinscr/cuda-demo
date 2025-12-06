cmake_minimum_required(VERSION 3.18)
project(cuda_demo LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Allow the user to override CUDA architectures (e.g. "60;70;75")
if(NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
  set(CMAKE_CUDA_ARCHITECTURES 50 CACHE STRING "CUDA architectures to build for")
endif()

find_package(CUDAToolkit REQUIRED)

set(SRC_DIR ${CMAKE_SOURCE_DIR}/src)
set(INC_DIR ${CMAKE_SOURCE_DIR}/include)

add_executable(vector_add ${SRC_DIR}/main.cu)
target_include_directories(vector_add PRIVATE ${INC_DIR})

# Use CUDAToolkit runtime library and ensure CUDA compilation flags
## Link against the CUDA runtime. Different CMake/CUDA combos export different imported targets,
## so try a few common names and error with a helpful message if none are available.
if(TARGET CUDAToolkit::cudart)
  target_link_libraries(vector_add PRIVATE CUDAToolkit::cudart)
elseif(TARGET CUDA::cudart)
  target_link_libraries(vector_add PRIVATE CUDA::cudart)
elseif(TARGET cudart)
  target_link_libraries(vector_add PRIVATE cudart)
else()
  message(FATAL_ERROR "Could not find an imported CUDA runtime target to link against. Ensure your CMake's CUDAToolkit provider is available. Targets tried: CUDAToolkit::cudart, CUDA::cudart, cudart.")
endif()

# Put binary in top-level build/bin so it's easy to run
set_target_properties(vector_add PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

message(STATUS "Using CUDA from: ${CUDAToolkit_ROOT}")

# Convenience target to remove the entire CMake build tree from the command line:
# Example: `cmake --build build --target distclean`
add_custom_target(distclean
  COMMAND ${CMAKE_COMMAND} -E echo "Removing CMake build directory: ${CMAKE_BINARY_DIR}"
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}
  COMMENT "Remove CMake build tree (distclean)"
)
