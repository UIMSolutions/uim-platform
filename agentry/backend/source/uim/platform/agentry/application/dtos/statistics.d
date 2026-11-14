/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.application.dtos.statistics;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Aggregated figures of one tenant (OData singleton "Statistics",
/// CLI "stats", GUI overview, Fiori KPI header).
struct AgentryStatistics {
  TenantId tenantId;

  size_t mobileApplications;
  size_t activeApplications;
  size_t appDefinitions;
  size_t publishedDefinitions;
  size_t appVersions;
  size_t publishedVersions;
  size_t devices;
  size_t activeDevices;
  size_t suspendedDevices;
  size_t syncSessions;
  size_t runningSyncs;
  size_t failedSyncs;
  size_t backendConnections;
  size_t connectionErrors;
  size_t deployments;
  size_t runningDeployments;
  size_t failedDeployments;
  long bytesTransferred;
  long recordsTransferred;
  long lastSyncAt;
  size_t[string] devicesByPlatform;

  Json toJson() const {
    auto platforms = Json.emptyObject;
    foreach (k, v; devicesByPlatform)
      platforms[k] = v;
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("mobileApplications", mobileApplications)
      .set("activeApplications", activeApplications)
      .set("appDefinitions", appDefinitions)
      .set("publishedDefinitions", publishedDefinitions)
      .set("appVersions", appVersions)
      .set("publishedVersions", publishedVersions)
      .set("devices", devices)
      .set("activeDevices", activeDevices)
      .set("suspendedDevices", suspendedDevices)
      .set("syncSessions", syncSessions)
      .set("runningSyncs", runningSyncs)
      .set("failedSyncs", failedSyncs)
      .set("backendConnections", backendConnections)
      .set("connectionErrors", connectionErrors)
      .set("deployments", deployments)
      .set("runningDeployments", runningDeployments)
      .set("failedDeployments", failedDeployments)
      .set("bytesTransferred", bytesTransferred)
      .set("recordsTransferred", recordsTransferred)
      .set("lastSyncAt", lastSyncAt)
      .set("devicesByPlatform", platforms);
  }
}
