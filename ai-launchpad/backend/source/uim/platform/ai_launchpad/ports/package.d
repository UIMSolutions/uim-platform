/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Ports: driving interfaces (use cases, application services) and driven
/// interfaces (repositories, storages, gateways, messaging).
module uim.platform.ai_launchpad.ports;

public {
  import uim.platform.ai_launchpad.ports.gateways;
  import uim.platform.ai_launchpad.ports.messaging;
  import uim.platform.ai_launchpad.ports.repositories;
  import uim.platform.ai_launchpad.ports.services;
  import uim.platform.ai_launchpad.ports.storages;
  import uim.platform.ai_launchpad.ports.usecases;
  import uim.platform.ai_launchpad.ports.driving;
}
