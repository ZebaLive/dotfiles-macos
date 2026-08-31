#include "cpu.h"
#include "../sketchybar.h"

int main (int argc, char** argv) {
  float update_freq;
  if (argc < 7 || (sscanf(argv[2], "%f", &update_freq) != 1)) {
    printf("Usage: %s \"<item-name>\" \"<update-freq>\" "
           "\"<blue>\" \"<yellow>\" \"<orange>\" \"<red>\"\n",
           argv[0]);
    exit(1);
  }

  alarm(0);
  struct cpu cpu = { 0 };
  cpu_init(&cpu);

  char update_message[1024];
  for (;;) {
    // Acquire new info
    cpu_update(&cpu);

    const char* color = argv[3];
    if (cpu.total_load > 30) {
      if (cpu.total_load < 60) color = argv[4];
      else if (cpu.total_load < 80) color = argv[5];
      else color = argv[6];
    }

    snprintf(update_message,
             1024,
             "--push '%s' '%.2f' "
             "--set '%s' graph.color='%s' label='cpu %02d%%' "
             "--set '%s.details.total' label='%02d%%' "
             "--set '%s.details.user' label='%d%%' "
             "--set '%s.details.system' label='%02d%%' "
             "--set '%s.details.idle' label='%02d%%'",
             argv[1], (double)cpu.total_load / 100.0,
             argv[1], color, cpu.total_load,
             argv[1], cpu.total_load,
             argv[1], cpu.user_load,
             argv[1], cpu.sys_load,
             argv[1], 100 - cpu.total_load                         );
    sketchybar(update_message);

    // Wait
    usleep(update_freq * 1000000);
  }
  return 0;
}
