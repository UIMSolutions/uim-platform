/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Ports: driving interfaces (use cases, application services) and driven
/// interfaces (repositories, storages, gateways, messaging).
module uim.platform.document_ai.ports;

public {
  import uim.platform.document_ai.ports.usecases;
  import uim.platform.document_ai.ports.services;
  import uim.platform.document_ai.ports.repositories;
  import uim.platform.document_ai.ports.storages;
  import uim.platform.document_ai.ports.messaging;
  import uim.platform.document_ai.ports.gateways;
  import uim.platform.document_ai.ports.driving;
}
