/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Infrastructure layer: configuration, logging, security, technical clients,
/// background workers and the dependency injection container.
module uim.platform.identity_authentication.infrastructure;

public {
  import uim.platform.identity_authentication.infrastructure.configuration;
  import uim.platform.identity_authentication.infrastructure.logging;
  import uim.platform.identity_authentication.infrastructure.security;
  import uim.platform.identity_authentication.infrastructure.clients;
  import uim.platform.identity_authentication.infrastructure.workers;
  import uim.platform.identity_authentication.infrastructure.container;
}
