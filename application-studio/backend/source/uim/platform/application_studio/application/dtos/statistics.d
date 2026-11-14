/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.dtos.statistics;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Aggregated figures of a tenant (Fiori KPI header, CLI "stats", GUI overview).
struct StudioStatistics {
  TenantId tenantId;
  int devSpaceTypes;
  int extensions;
  int extensionsDeprecated;
  int projectTemplates;
  int devSpaces;
  int devSpacesRunning;
  int devSpacesStopped;
  int devSpacesHibernated;
  int projects;
  int projectsArchived;
  int serviceBindings;
  int bindingsConnected;
  int runConfigurations;
  int runsActive;
  int buildConfigurations;
  int buildsSucceeded;
  int buildsFailed;
  int deployments;
  /// Objects in a transitional state (waiting for the reconciler).
  int pendingReconciliation;
  /// Most recent successful deployment (0 = none).
  long lastDeployAt;
}

/// Outcome of one reconciliation run.
struct ReconcileReport {
  TenantId tenantId;
  int examined;
  int advanced;
  string[] changes;
}

/// Outcome of installing the predefined catalogue.
struct CatalogSeedReport {
  TenantId tenantId;
  int created;
  int skipped;
  string[] items;
}
