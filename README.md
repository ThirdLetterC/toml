# toml-c

TOML v1.1 parser in C23.

* Requires a C23-capable compiler (`-std=c23` or `-std=c2x`).
* Implements [TOML v1.1](https://toml.io/en/v1.1.0).

## Usage

Parsing a TOML document creates a tree data structure rooted at
`toml_result_t::toptab`. Use `toml_get()` for a single key lookup or
`toml_seek()` for dotted multipart keys. Always call `toml_free(result)`
to release the associated memory.

You can simply compile `src/toml.c` and include `src/toml.h` in your
project without building a separate library.
See `src/toml.h` for the full API surface and data types.

The following is a simple example (mirrors `simple/simple.c`):

```c
/*
 * Parse the config file simple.toml:
 *
 * [server]
 * host = "www.example.com"
 * port = [8080, 8181, 8282]
 *
 */
#include "toml.h"
#include <stdlib.h>
#include <stdio.h>

static void error(const char *msg, const char *msg1) {
  fprintf(stderr, "ERROR: %s%s\n", msg, msg1 ? msg1 : "");
  exit(1);
}

int main() {
  constexpr const char *PATH = "simple.toml";

  // Parse the toml file
  auto result = toml_parse_file_ex(PATH);

  // Check for parse error
  if (!result.ok) {
    error(result.errmsg, nullptr);
  }

  // Extract values
  auto host = toml_seek(result.toptab, "server.host");
  auto port = toml_seek(result.toptab, "server.port");

  // Print server.host
  if (host.type != TOML_STRING) {
    error("missing or invalid 'server.host' property in config", nullptr);
  }
  printf("server.host = %s\n", host.u.s);

  // Print server.port
  if (port.type != TOML_ARRAY) {
    error("missing or invalid 'server.port' property in config", nullptr);
  }
  printf("server.port = [");
  for (int i = 0; i < port.u.arr.size; i++) {
    auto elem = port.u.arr.elem[i];
    if (elem.type != TOML_INT64) {
      error("server.port element not an integer", nullptr);
    }
    printf("%s%d", i ? ", " : "", (int)elem.u.int64);
  }
  printf("]\n");

  // Done!
  toml_free(result);
  return 0;
}
```


## Building

With `just`:

```bash
just build
just run
```

Manual build:

```bash
cc -std=c23 -Wall -Wextra -Wpedantic -Werror -Isrc -o simple/simple \
  simple/simple.c src/toml.c
```
