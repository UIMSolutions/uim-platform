/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.views.classes.templaters.helpers.directory;

import uim.views;

mixin(Version!("test_uim_views"));

@safe:

class DTemplaterDirectory : DDirectory!ITemplater {
  mixin(DirectoryThis!("Templater"));
}
mixin(DirectoryCalls!("Templater"));

unittest {
  auto directory = TemplaterDirectory;
  assert(testDirectory(directory, "Templater"), "Test TemplaterDirectory failed");
}