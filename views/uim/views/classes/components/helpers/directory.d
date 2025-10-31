/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.classes.components.helpers.directory;

import uim.views;

mixin(Version!("test_uim_views"));

@safe:

class DViewComponentDirectory : DDirectory!IViewComponent {
  mixin(DirectoryThis!("ViewComponent"));
}
mixin(DirectoryCalls!("ViewComponent"));

unittest {
  auto directory = new DViewComponentDirectory;
  assert(testDirectory(directory, "ViewComponent"), "Test ViewComponentDirectory failed");
}