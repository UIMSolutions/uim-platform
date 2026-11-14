/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Ports: driving (use cases, services) and driven (repositories, storages, gateways, messaging).
module uim.platform.task_center.ports;

public {
  import uim.platform.task_center.ports.repositories;
  import uim.platform.task_center.ports.storages;
  import uim.platform.task_center.ports.gateways;
  import uim.platform.task_center.ports.messaging;
  import uim.platform.task_center.ports.usecases;
  import uim.platform.task_center.ports.services;
  import uim.platform.task_center.ports.driving;
}
