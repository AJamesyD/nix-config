#pragma once

#include <mach/mach.h>
#include <mach/host_info.h>
#include <stdbool.h>

struct cpu_load {
  host_t host;
  mach_msg_type_number_t count;
  host_cpu_load_info_data_t load;
  host_cpu_load_info_data_t prev_load;
  bool has_prev;
};

static inline void cpu_init(struct cpu_load* cpu) {
  cpu->host = mach_host_self();
  cpu->has_prev = false;
  cpu->count = HOST_CPU_LOAD_INFO_COUNT;
}

static inline void cpu_update(struct cpu_load* cpu, int* user_load, int* sys_load, int* total_load) {
  *user_load = 0;
  *sys_load = 0;
  *total_load = 0;

  cpu->count = HOST_CPU_LOAD_INFO_COUNT;
  kern_return_t kr = host_statistics(cpu->host,
                                     HOST_CPU_LOAD_INFO,
                                     (host_info_t)&cpu->load,
                                     &cpu->count              );
  if (kr != KERN_SUCCESS) return;

  if (!cpu->has_prev) {
    cpu->prev_load = cpu->load;
    cpu->has_prev = true;
    return;
  }

  unsigned int delta_user = cpu->load.cpu_ticks[CPU_STATE_USER]
                          - cpu->prev_load.cpu_ticks[CPU_STATE_USER];
  unsigned int delta_sys  = cpu->load.cpu_ticks[CPU_STATE_SYSTEM]
                          - cpu->prev_load.cpu_ticks[CPU_STATE_SYSTEM];
  unsigned int delta_idle = cpu->load.cpu_ticks[CPU_STATE_IDLE]
                          - cpu->prev_load.cpu_ticks[CPU_STATE_IDLE];
  unsigned int delta_nice = cpu->load.cpu_ticks[CPU_STATE_NICE]
                          - cpu->prev_load.cpu_ticks[CPU_STATE_NICE];

  unsigned int delta_total = delta_user + delta_sys + delta_idle + delta_nice;

  if (delta_total > 0) {
    *user_load  = (int)(100.0 * (double)delta_user / (double)delta_total);
    *sys_load   = (int)(100.0 * (double)delta_sys  / (double)delta_total);
    *total_load = (int)(100.0 * (double)(delta_user + delta_sys) / (double)delta_total);
  }

  cpu->prev_load = cpu->load;
}
