/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.dtos.statistics;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Aggregated figures of a tenant (Fiori KPI header, CLI "stats", GUI overview).
struct KymaStatistics {
  TenantId tenantId;
  int environments;
  int environmentsRunning;
  int namespaces;
  int functions;
  int functionsRunning;
  int functionsFailed;
  int apiRules;
  int serviceInstances;
  int serviceBindings;
  int subscriptions;
  int subscriptionsPaused;
  int modulesEnabled;
  int applications;
  int applicationsConnected;
  /// Resources in a transitional state (waiting for the reconciler).
  int pendingReconciliation;
  /// Earliest expiry of a trial / free runtime (0 = none).
  long nextExpiryAt;
}

/// Outcome of one reconciliation run.
struct ReconcileReport {
  TenantId tenantId;
  int examined;
  int advanced;
  string[] changes;
}
