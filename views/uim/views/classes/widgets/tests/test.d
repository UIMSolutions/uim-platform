/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.views.classes.widgets.tests.test;

import uim.views;

mixin(Version!("test_uim_views"));

@safe:

bool testWidget(IWidget widget, string instanceName) {
  assert(widget !is null, widgetName ~ " is null");
  assert(widget.instanceName == instanceName, widgetName ~ " instanceName test failed");

  return true;
}