# justfile for toml

set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

ZIG := "zig"

# Format all C sources with clang-format
fmt:
  zig fmt build.zig
  find src simple -type f \( -name '*.c' -o -name '*.h' \) -print0 | xargs -0 clang-format -i

format: fmt

# Build the simple example program
build:
  {{ZIG}} build

# Build and run the simple example
run: build
  {{ZIG}} build run

# Clean build artifacts
clean:
  rm -rf zig-cache zig-out simple/simple
