/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Data Retention Manager service (SAP Data Retention Manager style):
/// application groups, legal entities and data subject roles; business
/// purposes with legal grounds, residence and retention rules; the data
/// subject lifecycle (active → blocked → archived → destroyed), end-of-purpose
/// checks, deletion requests (GDPR Art. 17) and archiving/destruction jobs.
///
/// Layers (hexagonal / clean architecture):
///   domain → ports → application → persistence / infrastructure → presentation
module uim.platform.data_retention;

public {
  import uim.platform.service;
  import uim.platform.data_retention.domain;
  import uim.platform.data_retention.ports;
  import uim.platform.data_retention.application;
  import uim.platform.data_retention.persistence;
  import uim.platform.data_retention.infrastructure;
  import uim.platform.data_retention.presentation;
}
