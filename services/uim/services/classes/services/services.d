/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.services.classes.services.services;

mixin(Version!("test_uim_services"));

import uim.services;
@safe:

class DServices : UIMObject {
    mixin(ServiceThis!());
}
