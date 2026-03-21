#pragma once

#include <sys/sysctl.h>
#include <sys/time.h>
#include <net/if.h>
#include <net/if_mib.h>
#include <string.h>
#include <stdio.h>
#include <stdbool.h>

struct network_load {
  uint64_t prev_ibytes;
  uint64_t prev_obytes;
  struct timeval prev_time;
  bool has_prev;
};

static inline void network_init(struct network_load* net) {
  net->has_prev = false;
}

static inline void format_bytes_per_sec(uint64_t bytes_per_sec, char* buf, int buf_size) {
  if (bytes_per_sec < 1000) {
    snprintf(buf, buf_size, "%03llu" "Bps", (unsigned long long)bytes_per_sec);
  } else if (bytes_per_sec < 1000000) {
    snprintf(buf, buf_size, "%03llu" "KBps", (unsigned long long)(bytes_per_sec / 1000));
  } else {
    snprintf(buf, buf_size, "%03llu" "MBps", (unsigned long long)(bytes_per_sec / 1000000));
  }
}

// Sum ibytes/obytes across all non-loopback interfaces via IFMIB
static inline bool network_get_totals(uint64_t* total_ib, uint64_t* total_ob) {
  int mib_count[] = { CTL_NET, PF_LINK, NETLINK_GENERIC, IFMIB_SYSTEM, IFMIB_IFCOUNT };
  int ifcount = 0;
  size_t len = sizeof(ifcount);
  if (sysctl(mib_count, 5, &ifcount, &len, NULL, 0) != 0) return false;

  *total_ib = 0;
  *total_ob = 0;
  for (int i = 1; i <= ifcount; i++) {
    int mib[] = { CTL_NET, PF_LINK, NETLINK_GENERIC, IFMIB_IFDATA, i, IFDATA_GENERAL };
    struct ifmibdata data;
    len = sizeof(data);
    if (sysctl(mib, 6, &data, &len, NULL, 0) != 0) continue;

    // Skip loopback
    if (data.ifmd_flags & IFF_LOOPBACK) continue;

    *total_ib += data.ifmd_data.ifi_ibytes;
    *total_ob += data.ifmd_data.ifi_obytes;
  }
  return true;
}

static inline void network_update(struct network_load* net, char* upload, char* download, int buf_size) {
  snprintf(upload, buf_size, "000Bps");
  snprintf(download, buf_size, "000Bps");

  uint64_t ibytes = 0, obytes = 0;
  if (!network_get_totals(&ibytes, &obytes)) return;

  struct timeval now;
  gettimeofday(&now, NULL);

  if (!net->has_prev) {
    net->prev_ibytes = ibytes;
    net->prev_obytes = obytes;
    net->prev_time = now;
    net->has_prev = true;
    return;
  }

  double dt = (double)(now.tv_sec - net->prev_time.tv_sec)
            + (double)(now.tv_usec - net->prev_time.tv_usec) / 1000000.0;

  if (dt <= 0.0) return;

  uint64_t download_rate = (uint64_t)((double)(ibytes - net->prev_ibytes) / dt);
  uint64_t upload_rate   = (uint64_t)((double)(obytes - net->prev_obytes) / dt);

  format_bytes_per_sec(upload_rate, upload, buf_size);
  format_bytes_per_sec(download_rate, download, buf_size);

  net->prev_ibytes = ibytes;
  net->prev_obytes = obytes;
  net->prev_time = now;
}
