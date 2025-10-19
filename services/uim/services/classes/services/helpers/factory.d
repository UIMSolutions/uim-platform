/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.services.helpers.factory;

import uim.services;

mixin(Version!("test_uim_services"));
@safe:

class DServiceFactory : DFactory!IService {
  mixin(FactoryThis!("Service"));
}

mixin(FactoryCalls!("Service"));

unittest {
  auto factory = new DServiceFactory();
  assert(testFactory(factory, "Service"), "Test ServiceFactory failed");
}
