/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Presentation layer (driving adapters).
module uim.platform.kyma.presentation;

public {
  import uim.platform.kyma.presentation.resources;
  import uim.platform.kyma.presentation.tabular;
  import uim.platform.kyma.presentation.http;
  import uim.platform.kyma.presentation.odata;
  import uim.platform.kyma.presentation.cli;
  import uim.platform.kyma.presentation.web;
  // GtkD GUI: imported explicitly by source/gui.d (only built with --config=gui)
}
