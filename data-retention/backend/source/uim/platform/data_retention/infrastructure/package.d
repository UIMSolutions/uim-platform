/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Infrastructure layer: configuration, logging, security, technical
/// clients, background workers and the composition root.
module uim.platform.data_retention.infrastructure;

public {
  import uim.platform.data_retention.infrastructure.configuration;
  import uim.platform.data_retention.infrastructure.logging;
  import uim.platform.data_retention.infrastructure.security;
  import uim.platform.data_retention.infrastructure.clients;
  import uim.platform.data_retention.infrastructure.workers;
  import uim.platform.data_retention.infrastructure.container;
}
