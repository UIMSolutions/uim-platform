/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.views.classes.views.helpers.directory;

import uim.views;

mixin(Version!("test_uim_views"));

@safe:

class DViewDirectory : DDirectory!IView {
  mixin(DirectoryThis!("View"));
}
mixin(DirectoryCalls!("View"));

unittest {
  auto directory = new DViewDirectory();
  assert(testDirectory(directory, "View"), "Test ViewDirectory failed");
}