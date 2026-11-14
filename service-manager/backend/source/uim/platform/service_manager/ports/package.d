/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Ports: driving (use cases, services) and driven (repositories, gateways).
/// The low-level storage port is IDocumentStore of uim-platform:service.
module uim.platform.service_manager.ports;

public {
  import uim.platform.service_manager.ports.driving;
  import uim.platform.service_manager.ports.repositories;
  import uim.platform.service_manager.ports.gateways;
  import uim.platform.service_manager.ports.usecases;
  import uim.platform.service_manager.ports.services;
}
