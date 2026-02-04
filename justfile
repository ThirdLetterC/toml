# justfile for tomlc17

set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

CC := "cc"
CFLAGS := "-std=c2x -D_XOPEN_SOURCE=600 -D_POSIX_C_SOURCE=200112L -Wall -Wextra -Wpedantic -Werror -Wstrict-prototypes -Wwrite-strings -Wno-missing-field-initializers -fPIC -Isrc"

# Format all C sources with clang-format
fmt:
  find src simple test -type f \( -name '*.c' -o -name '*.h' \) -print0 | xargs -0 clang-format -i

format: fmt

# Build the simple example program
build:
  {{CC}} {{CFLAGS}} -o simple/simple simple/simple.c src/tomlc17.c

# Build and run the simple example
run: build
  (cd simple && ./simple)

# Clean build artifacts
clean:
  rm -f simple/simple
