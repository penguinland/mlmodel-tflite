#!/bin/bash
# set -e: exit with errors if anything fails
#     -u: it's an error to use an undefined variable
#     -x: print out every command before it runs
#     -o pipefail: if something in the middle of a pipeline fails, the whole thing fails
set -euxo pipefail

# Set up conan
conan --version > /dev/null 2>&1 || python -m pip install conan
conan profile detect || echo "Conan is already installed"

# Clone the C++ SDK repo
mkdir -p tmp_cpp_sdk
pushd tmp_cpp_sdk
git clone https://github.com/viamrobotics/viam-cpp-sdk.git
pushd viam-cpp-sdk

# NOTE: If you change this version, also change it in the `conanfile.py` requirements
git remote add ethan https://github.com/stuqdog/cpp-sdk
git fetch ethan RSDK-10720-support-tcp-module-connections
git checkout ethan/RSDK-10720-support-tcp-module-connections

# Build the C++ SDK repo
#
# We want a static binary, so we turn off shared. Elect for C++17
# compilation, since it seems some of the dependencies we pick mandate
# it anyway.
conan create . \
      --build=missing \
      -o:a "&:shared=False" \
      -s:a build_type=Release \
      -s:a compiler.cppstd=17
conan export . --name=viam-cpp-sdk --version=0.11.1-tcp

# Cleanup
popd  # viam-cpp-sdk
popd  # tmp_cpp_sdk
rm -rf tmp_cpp_sdk
