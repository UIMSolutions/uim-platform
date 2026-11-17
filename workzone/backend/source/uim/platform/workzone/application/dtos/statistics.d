/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.dtos.statistics;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Aggregated figures of a tenant (Fiori KPI header, CLI "stats", GUI overview).
struct WorkzoneStatistics {
  TenantId tenantId;
  int workspaces;
  int workspacesActive;
  int members;
  int workpages;
  int widgets;
  int channels;
  int contentItems;
  int contentPublished;
  int feedEntries;
  int eventsUpcoming;
  int surveysActive;
  int forumTopicsOpen;
  int articlesPublished;
  int tasksOpen;
  int tasksOverdue;
  int notificationsUnread;
  int cards;
  int apps;
  int appsActive;
  int providersConnected;
  int shellPluginsActive;
  int sites;
  int sitesPublished;
  int users;
  int roles;
  int groups;
  /// Objects waiting for a time driven transition.
  int pendingHousekeeping;
  /// Most recent publication of content / articles (0 = none).
  long lastPublishedAt;
}

/// Outcome of one housekeeping run.
struct HousekeepingReport {
  TenantId tenantId;
  int examined;
  int changed;
  string[] changes;
}

/// Outcome of installing the predefined content.
struct SeedReport {
  TenantId tenantId;
  int created;
  int skipped;
  string[] items;
}
