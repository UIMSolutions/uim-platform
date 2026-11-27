/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Datasphere service (SAP Datasphere style business data fabric): spaces
/// with disk quotas and members, connections to source systems, remote
/// tables (federated or replicated), SQL views with semantic usage and
/// persistence, data flows, tasks and task chains with schedules and
/// retries, a run monitor, row level security (data access controls), a
/// governed catalog and the built-in JWT login.
///
/// Layers (hexagonal / clean architecture):
///   domain → ports → application → persistence / infrastructure → presentation
module uim.platform.datasphere;

public {
  import uim.platform.service;
  import uim.platform.datasphere.domain;
  import uim.platform.datasphere.ports;
  import uim.platform.datasphere.application;
  import uim.platform.datasphere.persistence;
  import uim.platform.datasphere.infrastructure;
  import uim.platform.datasphere.presentation;
}
