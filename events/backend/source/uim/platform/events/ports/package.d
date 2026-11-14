/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Ports: driving (use cases, services, messaging) and driven (repositories, storages, gateways).
module uim.platform.events.ports;

public {
  import uim.platform.events.ports.repositories;
  import uim.platform.events.ports.storages;
  import uim.platform.events.ports.gateways;
  import uim.platform.events.ports.usecases;
  import uim.platform.events.ports.services;
  import uim.platform.events.ports.messaging;
  import uim.platform.events.ports.driving;
}
