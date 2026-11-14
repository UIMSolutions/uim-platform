/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Infrastructure layer: configuration, security, logging and test helpers.
module uim.platform.service.infrastructure;

public:
  import uim.platform.service.infrastructure.configs;
  import uim.platform.service.infrastructure.configuration;
  import uim.platform.service.infrastructure.logging;
  import uim.platform.service.infrastructure.security;
  import uim.platform.service.infrastructure.tests;
  // Deprecated locations (moved to uim.platform.service.persistence)
  import uim.platform.service.infrastructure.repositories;
  import uim.platform.service.infrastructure.stores;
