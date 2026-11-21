/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Data Quality Management service (SAP Data Quality Management style):
/// datasets and records, validation rules and violations, data profiling,
/// duplicate detection with golden records, cleansing rules and jobs,
/// address cleansing, quality scorecards and trends.
///
/// Layers (hexagonal / clean architecture):
///   domain → ports → application → persistence / infrastructure → presentation
module uim.platform.data_quality;

public {
  import uim.platform.service;
  import uim.platform.data_quality.domain;
  import uim.platform.data_quality.ports;
  import uim.platform.data_quality.application;
  import uim.platform.data_quality.persistence;
  import uim.platform.data_quality.infrastructure;
  import uim.platform.data_quality.presentation;
}
