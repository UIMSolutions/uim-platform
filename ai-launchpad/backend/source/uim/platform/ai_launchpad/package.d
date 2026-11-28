/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// AI Launchpad service (SAP AI Launchpad style): one place to manage AI
/// runtimes and the machine learning life cycle — workspaces, connections to
/// AI runtimes (SAP AI Core or custom), resource groups, scenarios,
/// configurations, executions (training) and deployments (inference), a
/// model and dataset registry and the Generative AI hub (prompt collections
/// and prompts with a playground) — plus a launchpad of tiles and an
/// administration with users, roles, an audit log and the tile catalog.
///
/// Layers (hexagonal / clean architecture):
///   domain → ports → application → persistence / infrastructure → presentation
module uim.platform.ai_launchpad;

public {
  import uim.service;
  import uim.platform.ai_launchpad.domain;
  import uim.platform.ai_launchpad.ports;
  import uim.platform.ai_launchpad.application;
  import uim.platform.ai_launchpad.persistence;
  import uim.platform.ai_launchpad.infrastructure;
  import uim.platform.ai_launchpad.presentation;
}
