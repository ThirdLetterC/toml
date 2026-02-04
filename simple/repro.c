#include <stdio.h>

#include "toml.h"

static constexpr const char PATH[] = "/tmp/t.toml";

static void error(const char *msg, const char *msg1) {
  fprintf(stderr, "ERROR: %s%s\n", msg, msg1 ? msg1 : "");
}

[[nodiscard]] static bool setup() {
  const char *text =
      "[default]\n"
      "\n"
      "[wayland_displays.\"$WAYLAND_DISPLAY\"]\n"
      "seats = [ \"$XDG_SEAT\" ] \n"
      "[[clipboards.Default.mime_type_groups]]\n"
      "group = [ \"TEXT\", \"STRING\", \"UTF8_STRING\", \"text/plain\" ]\n"
      "xxxx xx xx\n";
  FILE *fp = fopen(PATH, "w");
  if (!fp) {
    error("fopen failed: ", PATH);
    return false;
  }
  if (fputs(text, fp) == EOF) {
    error("failed to write fixture: ", PATH);
    fclose(fp);
    return false;
  }
  if (fclose(fp) != 0) {
    error("failed to close fixture: ", PATH);
    return false;
  }
  return true;
}

[[nodiscard]] static bool run() {
  auto root = toml_parse_file_ex(PATH);

  if (!root.ok) {
    fprintf(stderr, "toml_parse_file_ex: %s\n", root.errmsg);
    toml_free(root);
    return false;
  }

  auto wayland_displays = toml_seek(root.toptab, "main.wayland_displays");
  auto clipboards = toml_seek(root.toptab, "main.clipboards");

  printf("wayland_displays: %d\n", wayland_displays.type);
  printf("clipboards: %d\n", clipboards.type);

  toml_free(root);
  return true;
}

int main() {
  constexpr int kExitOk = 0;
  constexpr int kExitFail = 1;

  if (!setup()) {
    return kExitFail;
  }
  if (!run()) {
    return kExitFail;
  }
  return kExitOk;
}
