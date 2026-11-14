/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// SAP BTP Service Manager style service: registry of platforms and service
/// brokers, service catalog (offerings / plans), provisioning of service
/// instances and bindings with asynchronous operation tracking, and labels.
///
/// Layers (hexagonal / clean architecture):
///   domain → ports → application → persistence / infrastructure → presentation
module uim.platform.service_manager;

public {
  import uim.platform.service;

  import uim.platform.service_manager.domain;
  import uim.platform.service_manager.ports;
  import uim.platform.service_manager.application;
  import uim.platform.service_manager.persistence;
  import uim.platform.service_manager.infrastructure;
  import uim.platform.service_manager.presentation;
}
