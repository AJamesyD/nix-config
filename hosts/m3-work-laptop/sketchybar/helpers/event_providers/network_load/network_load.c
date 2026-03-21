#include "../sketchybar.h"
#include "network.h"
#include <unistd.h>

int main(int argc, char** argv) {
  if (argc < 3) {
    printf("Usage: network_load <event_name> <update_freq_secs>\n");
    exit(1);
  }

  char* event_name = argv[1];
  float update_freq = strtof(argv[2], NULL);

  char event_message[256];
  snprintf(event_message, sizeof(event_message),
           "--add event %s", event_name);
  sketchybar(event_message);

  struct network_load net;
  network_init(&net);

  char upload[32];
  char download[32];
  char trigger[256];

  for (;;) {
    network_update(&net, upload, download, sizeof(upload));

    snprintf(trigger, sizeof(trigger),
             "--trigger %s upload='%s' download='%s'",
             event_name, upload, download);
    sketchybar(trigger);

    usleep((useconds_t)(update_freq * 1000000));
  }
  return 0;
}
