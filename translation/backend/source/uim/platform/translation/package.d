/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Translation Hub service — hexagonal architecture:
///   domain ← ports ← application ← persistence / infrastructure ← presentation
module uim.platform.translation;

public {
  import uim.platform.service;

  import uim.platform.translation.helpers;
  import uim.platform.translation.domain;
  import uim.platform.translation.ports;
  import uim.platform.translation.application;
  import uim.platform.translation.persistence;
  import uim.platform.translation.infrastructure;
  import uim.platform.translation.presentation;
}
