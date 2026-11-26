/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Application Event Hub service (SAP Cloud Application Event Hub style):
/// formations of registered SAP cloud systems, a catalog of event types
/// (topics), delivery channels (webhook, queue), subscriptions with filters,
/// CloudEvents publishing and routing, reliable delivery with retries and
/// exponential back-off, dead-letter handling and the built-in JWT login.
/// 
/// Layers (hexagonal / clean architecture):
///   domain → ports → application → persistence / infrastructure → presentation
module uim.platform.application_events;

public {
  import uim.platform.service;
  import uim.platform.application_events.domain;
  import uim.platform.application_events.ports;
  import uim.platform.application_events.application;
  import uim.platform.application_events.persistence;
  import uim.platform.application_events.infrastructure;
  import uim.platform.application_events.presentation;
}
