/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.web;

mixin(ImportPhobos!());

public { // uim libraries
  import uim.infralevel;
  import uim.models;
}

public { // uim.filesystem libraries
  import uim.web.classes;
  import uim.web.collections;
  import uim.web.exceptions;
  import uim.web.factories;
  import uim.web.helpers;
  import uim.web.interfaces;
  import uim.web.mixins;
  import uim.web.registries;
  import uim.web.tests;
}
