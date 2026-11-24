/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Ports: driving interfaces (use cases, application services) and driven
/// interfaces (repositories, storages, gateways, messaging).
module uim.platform.data_retention.ports;

public {
  import uim.platform.data_retention.ports.usecases;
  import uim.platform.data_retention.ports.services;
  import uim.platform.data_retention.ports.repositories;
  import uim.platform.data_retention.ports.storages;
  import uim.platform.data_retention.ports.messaging;
  import uim.platform.data_retention.ports.gateways;
  import uim.platform.data_retention.ports.driving;
}
