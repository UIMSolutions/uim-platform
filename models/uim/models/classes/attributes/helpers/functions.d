mod/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
moduleule uim.models.classes.attributes.helpers.functions;

import uim.models;

mixin(Version!"test_uim_models");

@safe:

bool isAttribute(Object obj) {
  if (obj is null) {
    return false;
  }
  return cast(IAttribute)obj !is null;
}