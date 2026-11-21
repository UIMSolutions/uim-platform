/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Ports: the interfaces between the application core and its adapters.
///   usecases      driving ports (implemented by the application, used by presentation)
///   repositories  driven ports for the aggregates (implemented by persistence)
///   storages      driven port of the low level document store
///   messaging     driven port for domain events
///   gateways      driven ports for technical services (clock)
module uim.platform.architecture.ports;

public {
  import uim.platform.architecture.ports.usecases;
  import uim.platform.architecture.ports.repositories;
  import uim.platform.architecture.ports.storages;
  import uim.platform.architecture.ports.messaging;
  import uim.platform.architecture.ports.gateways;
}
