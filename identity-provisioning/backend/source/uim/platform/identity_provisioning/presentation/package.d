/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Presentation layer (driving adapters).
module uim.platform.identity_provisioning.presentation;

public {
  import uim.platform.identity_provisioning.presentation.resources;
  import uim.platform.identity_provisioning.presentation.tabular;
  import uim.platform.identity_provisioning.presentation.http;
  import uim.platform.identity_provisioning.presentation.odata;
  import uim.platform.identity_provisioning.presentation.cli;
  import uim.platform.identity_provisioning.presentation.web;
  // GtkD GUI: imported explicitly by source/gui.d (only built with --config=gui)
}
