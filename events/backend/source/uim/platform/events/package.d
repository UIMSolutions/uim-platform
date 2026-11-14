/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// SAP Event Mesh style service: messaging services with namespaces, message
/// clients, queues with topic subscriptions, webhooks (push delivery), event
/// channels and client bindings — plus topic based publishing, queue
/// consumption, redelivery and dead-lettering.
///
/// Layers (hexagonal / clean architecture):
///   domain → ports → application → persistence / infrastructure → presentation
module uim.platform.events;

public {
  import uim.platform.service;

  import uim.platform.events.domain;
  import uim.platform.events.ports;
  import uim.platform.events.application;
  import uim.platform.events.persistence;
  import uim.platform.events.infrastructure;
  import uim.platform.events.presentation;
}
