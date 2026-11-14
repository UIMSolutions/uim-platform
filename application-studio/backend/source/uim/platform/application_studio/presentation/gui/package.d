/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Desktop GUI integration (GtkD 3). Only available in the "gui" dub configuration.
module uim.platform.application_studio.presentation.gui;

version (Have_gtk_d) {
  public import uim.platform.application_studio.presentation.gui.window;
}
