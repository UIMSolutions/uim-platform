/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Identity Authentication service (SAP Cloud Identity Services – Authentication style).
///
/// Hexagonal layout:
///   domain → ports → application → persistence / infrastructure → presentation
module uim.platform.identity_authentication;

public {
  import uim.platform.service;

  import uim.platform.identity_authentication.domain;
  import uim.platform.identity_authentication.ports;
  import uim.platform.identity_authentication.application;
  import uim.platform.identity_authentication.persistence;
  import uim.platform.identity_authentication.infrastructure;
  import uim.platform.identity_authentication.presentation;
}
