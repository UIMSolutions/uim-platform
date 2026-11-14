/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.dtos.statistics;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Aggregated figures of a tenant (Fiori KPI header, CLI "stats", GUI overview).
struct AbapStatistics {
  TenantId tenantId;
  int systems;
  int systemsActive;
  int softwareComponents;
  int componentsCloned;
  int communicationArrangements;
  int serviceBindings;
  int serviceBindingsPublished;
  int businessUsers;
  int usersLocked;
  int businessRoles;
  int transportsOpen;
  int transportsReleased;
  int transportsImported;
  int applicationJobs;
  int jobsScheduled;
  int jobsFailed;
  /// Objects in a transitional state (waiting for the reconciler).
  int pendingReconciliation;
  /// Next planned job start (0 = none).
  long nextJobAt;
}

/// Outcome of one reconciliation run.
struct ReconcileReport {
  TenantId tenantId;
  int examined;
  int advanced;
  string[] changes;
}
