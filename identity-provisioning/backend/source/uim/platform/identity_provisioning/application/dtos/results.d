/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.application.dtos.results;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Outcome of a scheduler pass (runDue).
struct JobRunReport {
  TenantId tenantId;
  int processed;
  int completed;
  int failed;
  string[] messages;
  long ranAt;
}

/// A transformation applied to sample attributes.
struct TransformationPreview {
  string transformationName;
  EntityType entityType = EntityType.user;
  bool accepted;
  bool failed;
  string reason;
  string checksum;
  Attribute[] attributes;
}

/// Aggregated figures of a tenant (Fiori KPI header, CLI "stats", GUI overview).
struct ProvisioningStatistics {
  TenantId tenantId;
  int sourceSystems;
  int sourceSystemsActive;
  int targetSystems;
  int targetSystemsActive;
  int proxySystems;
  int proxySystemsActive;
  int systemsInError; /// all roles
  int transformations;
  int transformationsActive;
  int jobs;
  int jobsScheduled; /// intervalMinutes > 0 and not cancelled
  int jobsCompleted;
  int jobsFailed;
  int jobsCancelled;
  int runs; /// sum of all job runs
  int provisionedEntities;
  int provisionedUsers;
  int provisionedGroups;
  int provisionedErrors;
  int logs;
  int logsFailed;
  long lastRunAt;
}
