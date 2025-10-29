/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.views.classes.templaters.tests.test;

import uim.views;

mixin(Version!("test_uim_views"));

@safe:

bool testTemplater(ITemplater templater, string instanceName) {
  assert(templater !is null, "Templater is null");
  assert(templater.instanceName == instanceName, "Instance name does not match");
  return true;
}
