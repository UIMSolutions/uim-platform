/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Cloud Portal service (SAP Build Work Zone / Fiori launchpad site manager style)
/// — hexagonal architecture:
///   domain ← ports ← application ← persistence / infrastructure ← presentation
module uim.platform.portal;

public {
  import uim.platform.service;

  import uim.platform.portal.helpers;
  import uim.platform.portal.domain;
  import uim.platform.portal.ports;
  import uim.platform.portal.application;
  import uim.platform.portal.persistence;
  import uim.platform.portal.infrastructure;
  import uim.platform.portal.presentation;
}
