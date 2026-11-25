/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Integration Automation service (SAP Cloud Integration Automation style):
/// a system landscape and destinations, integration scenarios with task
/// templates, guided workflows instantiated from active scenarios, manual,
/// approval, automated and notification tasks with dependencies, automated
/// execution through destinations, execution logs and monitoring.
///
/// Layers (hexagonal / clean architecture):
///   domain → ports → application → persistence / infrastructure → presentation
module uim.platform.integration_automation;

public {
  import uim.platform.service;
  import uim.platform.integration_automation.domain;
  import uim.platform.integration_automation.ports;
  import uim.platform.integration_automation.application;
  import uim.platform.integration_automation.persistence;
  import uim.platform.integration_automation.infrastructure;
  import uim.platform.integration_automation.presentation;
}
