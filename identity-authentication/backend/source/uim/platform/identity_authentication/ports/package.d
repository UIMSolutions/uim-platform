/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Ports: driving (use cases, services) and driven (repositories, storages,
/// messaging, gateways) interfaces of the hexagon.
module uim.platform.identity_authentication.ports;

public {
  import uim.platform.identity_authentication.ports.driving;
  import uim.platform.identity_authentication.ports.gateways;
  import uim.platform.identity_authentication.ports.messaging;
  import uim.platform.identity_authentication.ports.repositories;
  import uim.platform.identity_authentication.ports.services;
  import uim.platform.identity_authentication.ports.storages;
  import uim.platform.identity_authentication.ports.usecases;
}
