# Zen Browser about:config preferences enforced via user.js.
# Extracted from prefs.js — only intentional settings, not session state.
{
  # -- Zen-specific --
  "zen.tabs.vertical.right-side" = true;
  "zen.view.compact.enable-at-startup" = true;
  "zen.view.compact.hide-toolbar" = true;
  "zen.view.compact.should-enable-at-startup" = true;
  "zen.view.compact.toolbar-flash-popup" = true;
  "zen.view.use-single-toolbar" = false;
  "zen.view.window.scheme" = 0;
  "zen.view.experimental-no-window-controls" = true;
  "zen.view.grey-out-inactive-windows" = false;
  "zen.view.compact.toolbar-hide-after-hover.duration" = 500;
  "zen.theme.gradient.show-custom-colors" = true;
  "zen.watermark.enabled" = false;

  # -- Browser behavior --
  "browser.contentblocking.category" = "strict";
  "browser.download.useDownloadDir" = false;
  "browser.formfill.enable" = true;
  "browser.tabs.inTitlebar" = 1;
  "browser.theme.toolbar-theme" = 0;
  "browser.urlbar.suggest.clipboard" = false;
  "browser.urlbar.suggest.quicksuggest.sponsored" = false;

  # -- Privacy & Security --
  "dom.security.https_only_mode" = true;
  "network.dns.disablePrefetch" = true;
  "network.http.referer.disallowCrossSiteRelaxingDefault.top_navigation" = true;
  "network.http.speculative-parallel-limit" = 0;
  "network.prefetch-next" = false;
  "privacy.annotate_channels.strict_list.enabled" = true;
  "privacy.bounceTrackingProtection.mode" = 1;
  "privacy.fingerprintingProtection" = true;
  "privacy.query_stripping.enabled" = true;
  "privacy.query_stripping.enabled.pbmode" = true;
  "privacy.trackingprotection.emailtracking.enabled" = true;
  "privacy.trackingprotection.enabled" = true;
  "privacy.trackingprotection.socialtracking.enabled" = true;

  # -- Extensions --
  "extensions.formautofill.addresses.enabled" = false;
  "extensions.formautofill.creditCards.enabled" = false;

  # -- General preferences --
  "accessibility.typeaheadfind.flashBar" = 0;
  "findbar.highlightAll" = true;
  "layout.css.prefers-color-scheme.content-override" = 0;
  "nimbus.rollouts.enabled" = false;
  "sidebar.visibility" = "hide-sidebar";
  "browser.sessionstore.restore_pinned_tabs_on_demand" = true;

  # -- Power optimization --
  # Throttle background tab JS timers from 1s to 10s. With 20+ tabs across
  # workspaces (which Zen keeps fully loaded), this cuts CPU wake-ups
  # significantly. Failure mode: stale data until tab is focused.
  "dom.min_background_timeout_value" = 10000;
  # Unload inactive tabs after 5 min (default 10). More aggressive given
  # this machine regularly hits memory pressure with 20+ tabs.
  "zen.tab-unloader.timeout-minutes" = 5;

  # -- Memory optimization --
  # Reduce site-isolated content processes (default 4). Trades crash/security
  # isolation for lower per-process memory overhead. Kept at 2 (not 1) because
  # this machine handles AWS credentials via container tabs.
  "dom.ipc.processCount.webIsolated" = 2;
  "dom.ipc.processPrelaunch.fission.number" = 1;
  # 5 minutes (in ms); default is 10 minutes
  "browser.tabs.min_inactive_duration_before_unload" = 300000;
  "browser.sessionhistory.max_total_viewers" = 4;
  "browser.sessionhistory.max_entries" = 25;
  "browser.sessionstore.max_tabs_undo" = 10;

  # -- Zen sidebar mods --
  "uc.zen-sidebar.float-at-right-side" = true;
  "uc.zen-sidebar.pin-at-right-side" = true;
}
