/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Agentry service — metadata-driven mobile application platform.
///
/// Hexagonal layout:
///   domain → ports → application → persistence / infrastructure → presentation
module uim.platform.agentry;

public {
  import uim.platform.service;

  import uim.platform.agentry.domain;
  import uim.platform.agentry.ports;
  import uim.platform.agentry.application;
  import uim.platform.agentry.persistence;
  import uim.platform.agentry.infrastructure;
  import uim.platform.agentry.presentation;
}
