/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Ports: driving interfaces (use cases, application services) and driven
/// interfaces (repositories, storages, gateways, messaging).
module uim.platform.application_autoscaler.ports;

public {
  import uim.platform.application_autoscaler.ports.usecases;
  import uim.platform.application_autoscaler.ports.services;
  import uim.platform.application_autoscaler.ports.repositories;
  import uim.platform.application_autoscaler.ports.storages;
  import uim.platform.application_autoscaler.ports.messaging;
  import uim.platform.application_autoscaler.ports.gateways;
  import uim.platform.application_autoscaler.ports.driving;
}
