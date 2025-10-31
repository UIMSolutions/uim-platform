/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.services.classes.services.helpers.functions;

import uim.services;

mixin(Version!("test_uim_services"));

@safe:

bool isService(Object obj) {
  if (obj is null) {
    return false;
  }
  return cast(IService)obj !is null;
}