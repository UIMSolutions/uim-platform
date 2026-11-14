/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Application Studio service — hexagonal architecture:
///   domain ← ports ← application ← persistence / infrastructure ← presentation
module uim.platform.application_studio;

public {
  import uim.platform.service;

  import uim.platform.application_studio.helpers;
  import uim.platform.application_studio.domain;
  import uim.platform.application_studio.ports;
  import uim.platform.application_studio.application;
  import uim.platform.application_studio.persistence;
  import uim.platform.application_studio.infrastructure;
  import uim.platform.application_studio.presentation;
}
