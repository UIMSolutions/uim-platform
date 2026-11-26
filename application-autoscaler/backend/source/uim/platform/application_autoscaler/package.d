/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Application Autoscaler service (SAP BTP Application Autoscaler style):
/// applications bound to the service, scaling policies with instance
/// limits, dynamic scaling rules on standard and custom metrics (breach
/// duration, cool-down, absolute and percentage adjustments), recurring and
/// specific-date schedules, metric ingestion, the scaling engine and an
/// immutable scaling history.
///
/// Layers (hexagonal / clean architecture):
///   domain → ports → application → persistence / infrastructure → presentation
module uim.platform.application_autoscaler;

public {
  import uim.platform.service;
  import uim.platform.application_autoscaler.domain;
  import uim.platform.application_autoscaler.ports;
  import uim.platform.application_autoscaler.application;
  import uim.platform.application_autoscaler.persistence;
  import uim.platform.application_autoscaler.infrastructure;
  import uim.platform.application_autoscaler.presentation;
}
