/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.models.classes.attributes.helpers.directory;

import uim.models;

mixin(Version!"test_uim_models");

@safe:

class DAttributeDirectory : DObjectDirectory!IAttribute {
  mixin(DirectoryThis!"Attribute");
}

mixin(DirectoryCalls!"Attribute");

unittest {
  auto directory = new DAttributeDirectory();
  assert(testDirectory(directory, "Attribute"), "AttributeDirectory test failed!");
}
