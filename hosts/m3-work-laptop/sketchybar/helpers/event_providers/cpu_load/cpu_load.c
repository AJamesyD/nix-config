#include "../sketchybar.h"
#include "cpu.h"
#include <unistd.h>

int main(int argc, char** argv) {
  if (argc < 3) {
    printf("Usage: cpu_load <event_name> <update_freq_secs>\n");
    exit(1);
  }

  char* event_name = argv[1];
  float update_freq = strtof(argv[2], NULL);

  char event_message[256];
  snprintf(event_message, sizeof(event_message),
           "--add event %s", event_name);
  sketchybar(event_message);

  struct cpu_load cpu;
  cpu_init(&cpu);

  char trigger[256];
  for (;;) {
    int user, sys, total;
    cpu_update(&cpu, &user, &sys, &total);

    snprintf(trigger, sizeof(trigger),
             "--trigger %s user_load=%d sys_load=%d total_load=%d",
             event_name, user, sys, total);
    sketchybar(trigger);

    usleep((useconds_t)(update_freq * 1000000));
  }
  return 0;
}
