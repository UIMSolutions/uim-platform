/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim-platform.models.uim.models.classes.attributes.interfaces;

import uim.models;
mixin(Version!"test_uim_models");

@safe:

interface IAttribute : IObject {
  // Data formats of the attribute. 
  // string[] dataFormats(); 

  // Check for data format
  // bool hasDataFormat(string dataFormatName);
}