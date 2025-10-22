/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.services.classes.services.helpers.directory;

import uim.services;

mixin(Version!("test_uim_services"));

@safe:

class DServiceDirectory : DDirectory!IService {
  mixin(DirectoryThis!("Service"));
}
mixin(DirectoryCalls!("Service"));

unittest {
  auto directory = ServiceDirectory;
  assert(testDirectory(directory, "Service"), "Test ServiceDirectory failed");
}