/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Authorization Management Service in the style of SAP Cloud Identity Services
/// AMS: applications and their APIs, base / custom authorization policies with
/// attribute conditions, policy assignments to users and groups, runtime
/// authorization decisions and a decision log.
///
/// Layers (hexagonal / clean architecture):
///   domain → ports → application → persistence / infrastructure → presentation
module uim.platform.authorization;

public {
  import uim.platform.service;

  import uim.platform.authorization.domain;
  import uim.platform.authorization.ports;
  import uim.platform.authorization.application;
  import uim.platform.authorization.persistence;
  import uim.platform.authorization.infrastructure;
  import uim.platform.authorization.presentation;
}
