/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.application.dtos.statistics;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Aggregated key figures of a tenant's transport landscape.
struct TransportStatistics {
  TenantId tenantId;
  size_t nodes;
  size_t enabledNodes;
  size_t routes;
  size_t enabledRoutes;
  size_t requests;
  size_t queueEntries;
  size_t pendingImports;
  size_t runningImports;
  size_t failedImports;
  size_t successfulImports;
  size_t actions;
  long lastActionAt;
  size_t[string] requestsByStatus;
  size_t[string] requestsByContentType;

  Json toJson() const {
    Json map(const size_t[string] m) {
      auto j = Json.emptyObject;
      foreach (k; m.keys.sort)
        j[k] = cast(long) m[k];
      return j;
    }

    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("nodes", nodes)
      .set("enabledNodes", enabledNodes)
      .set("routes", routes)
      .set("enabledRoutes", enabledRoutes)
      .set("requests", requests)
      .set("queueEntries", queueEntries)
      .set("pendingImports", pendingImports)
      .set("runningImports", runningImports)
      .set("failedImports", failedImports)
      .set("successfulImports", successfulImports)
      .set("actions", actions)
      .set("lastActionAt", lastActionAt)
      .set("requestsByStatus", map(requestsByStatus))
      .set("requestsByContentType", map(requestsByContentType));
  }
}
