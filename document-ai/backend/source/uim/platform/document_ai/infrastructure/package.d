/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Infrastructure layer: configuration, logging, security, monitoring,
/// technical clients, background workers and the composition root.
module uim.platform.document_ai.infrastructure;

public {
  import uim.platform.document_ai.infrastructure.configuration;
  import uim.platform.document_ai.infrastructure.logging;
  import uim.platform.document_ai.infrastructure.security;
  import uim.platform.document_ai.infrastructure.monitoring;
  import uim.platform.document_ai.infrastructure.clients;
  import uim.platform.document_ai.infrastructure.workers;
  import uim.platform.document_ai.infrastructure.container;
}
