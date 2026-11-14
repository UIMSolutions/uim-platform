/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// ABAP environment service — hexagonal architecture:
///   domain ← ports ← application ← persistence / infrastructure ← presentation
module uim.platform.abap_environment;

public {
  import uim.platform.service;

  import uim.platform.abap_environment.helpers;
  import uim.platform.abap_environment.domain;
  import uim.platform.abap_environment.ports;
  import uim.platform.abap_environment.application;
  import uim.platform.abap_environment.persistence;
  import uim.platform.abap_environment.infrastructure;
  import uim.platform.abap_environment.presentation;
}
