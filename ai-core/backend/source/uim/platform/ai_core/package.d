/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// AI Core service (SAP AI Core style): the machine learning lifecycle of
/// the AI API v2 — resource groups, scenarios, executables, configurations,
/// executions (training), deployments (serving), artifacts, metrics,
/// execution schedules and the secrets of docker registries / object stores.
///
/// Layers (hexagonal / clean architecture):
///   domain → ports → application → persistence / infrastructure → presentation
module uim.platform.ai_core;

public {
  import uim.platform.service;
  import uim.platform.ai_core.domain;
  import uim.platform.ai_core.ports;
  import uim.platform.ai_core.application;
  import uim.platform.ai_core.persistence;
  import uim.platform.ai_core.infrastructure;
  import uim.platform.ai_core.presentation;
}
