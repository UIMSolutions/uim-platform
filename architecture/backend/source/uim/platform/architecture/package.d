/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Architecture repository service: TOGAF building blocks (architecture,
/// solution, data, business and technology building blocks), ArchiMate 3.2
/// relationships between them, lifecycle governance, gap and impact
/// analysis and export in the ArchiMate Model Exchange File Format.
///
/// Layers (hexagonal / clean architecture):
///   domain → ports → application → persistence / infrastructure → presentation
module uim.platform.architecture;

public {
  import uim.platform.service;
  import uim.platform.architecture.domain;
  import uim.platform.architecture.ports;
  import uim.platform.architecture.application;
  import uim.platform.architecture.persistence;
  import uim.platform.architecture.infrastructure;
  import uim.platform.architecture.presentation;
}
