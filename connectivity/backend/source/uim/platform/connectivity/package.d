/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// ABAP environment service — hexagonal architecture:
///   domain ← ports ← application ← persistence / infrastructure ← presentation
module uim.platform.connectivity;

public {
  import uim.platform.service;

  import uim.platform.connectivity.helpers;
  import uim.platform.connectivity.domain;
  import uim.platform.connectivity.ports;
  import uim.platform.connectivity.application;
  import uim.platform.connectivity.persistence;
  import uim.platform.connectivity.infrastructure;
  import uim.platform.connectivity.presentation;
}
