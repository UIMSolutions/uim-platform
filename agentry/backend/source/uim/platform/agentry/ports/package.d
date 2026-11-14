/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Ports: driving (use cases, services) and driven (repositories, storages,
/// messaging, gateways) interfaces of the hexagon.
module uim.platform.agentry.ports;

public {
  import uim.platform.agentry.ports.driving;
  import uim.platform.agentry.ports.gateways;
  import uim.platform.agentry.ports.messaging;
  import uim.platform.agentry.ports.repositories;
  import uim.platform.agentry.ports.services;
  import uim.platform.agentry.ports.storages;
  import uim.platform.agentry.ports.usecases;
}
