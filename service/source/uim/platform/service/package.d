/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Umbrella module of the service library.
///
/// The protocol adapters are opt-in and must be imported explicitly, so their
/// names never clash with service specific adapters:
///   import uim.platform.service.presentation.odata;  // OData v4 (Fiori)
///   import uim.platform.service.presentation.cli;    // command line
///   import uim.platform.service.presentation.gui;    // GtkD desktop GUI
module uim.platform.service;

public {
  import uim.framework;
  import uim.services;

  import uim.platform.service.application;
  import uim.platform.service.classes;
  import uim.platform.service.domain;
  import uim.platform.service.exceptions;
  import uim.platform.service.helpers;
  import uim.platform.service.interfaces;
  import uim.platform.service.mixins;
  import uim.platform.service.ports;
  import uim.platform.service.persistence;
  import uim.platform.service.infrastructure;
  import uim.platform.service.presentation;
  import uim.platform.service.tests;
  import uim.platform.service.udas;
}
