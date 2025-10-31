/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.models.classes.attributes.helpers.factory;

mixin(Version!"test_uim_models");

import uim.models;

@safe:

class DAttributeFactory : DObjectFactory!IAttribute {
  mixin(FactoryThis!"Attribute");
}

mixin(FactoryCalls!"Attribute");

unittest {
  auto factory = new DAttributeFactory();
  assert(testFactory(factory, "Attribute"), "AttributeFactory test failed!");
}
