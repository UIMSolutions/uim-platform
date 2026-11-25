/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Ports: driving interfaces (use cases, application services) and driven
/// interfaces (repositories, storages, gateways, messaging).
module uim.platform.integration_automation.ports;

public {
  import uim.platform.integration_automation.ports.usecases;
  import uim.platform.integration_automation.ports.services;
  import uim.platform.integration_automation.ports.repositories;
  import uim.platform.integration_automation.ports.storages;
  import uim.platform.integration_automation.ports.messaging;
  import uim.platform.integration_automation.ports.gateways;
  import uim.platform.integration_automation.ports.driving;
}
