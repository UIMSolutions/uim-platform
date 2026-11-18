/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Object Store service — hexagonal architecture:
///   domain ← ports ← application ← persistence / infrastructure ← presentation
module uim.platform.object_store;

public {
  import uim.platform.service;

  import uim.platform.object_store.helpers;
  import uim.platform.object_store.domain;
  import uim.platform.object_store.ports;
  import uim.platform.object_store.application;
  import uim.platform.object_store.persistence;
  import uim.platform.object_store.infrastructure;
  import uim.platform.object_store.presentation;
}
