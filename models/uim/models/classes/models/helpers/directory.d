/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.models.classes.models.helpers.directory;

import uim.models;

mixin(Version!"test_uim_models");

@safe:

class DModelDirectory : DDirectory!IModel {
  mixin(DirectoryThis!("Model"));
}
mixin(DirectoryCalls!("Model"));

unittest {
  auto directory = ModelDirectory;
  assert(testDirectory(directory, "Model"), "Test ModelDirectory failed");
}