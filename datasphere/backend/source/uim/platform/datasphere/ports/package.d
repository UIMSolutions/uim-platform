/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Ports: driving interfaces (use cases, application services) and driven
/// interfaces (repositories, storages, gateways, messaging).
module uim.platform.datasphere.ports;

public {
  import uim.platform.datasphere.ports.gateways;
  import uim.platform.datasphere.ports.messaging;
  import uim.platform.datasphere.ports.repositories;
  import uim.platform.datasphere.ports.services;
  import uim.platform.datasphere.ports.storages;
  import uim.platform.datasphere.ports.usecases;
  import uim.platform.datasphere.ports.driving;
}
