/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.application.dtos.statistics;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// Aggregated figures of one tenant.
struct ServiceManagerStatistics {
  TenantId tenantId;
  size_t platforms, activePlatforms;
  size_t brokers, activeBrokers, failedBrokers;
  size_t offerings, availableOfferings;
  size_t plans;
  size_t instances, readyInstances, pendingInstances, failedInstances;
  size_t bindings;
  size_t operations, runningOperations, failedOperations;
  size_t labels;
}
