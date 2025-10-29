/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.classes.widgets.errors.error;

import uim.views;

mixin(Version!("test_uim_views"));

@safe:

class DWidgetError : DError!IWidget {
  mixin(ErrorThis!("Widget"));
}