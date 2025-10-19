/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim-platform.services.uim.services.classes.services.service;

import uim.services;
mixin(Version!("test_uim_services"));

@safe:

class DService : UIMObject, IService {
    mixin(ServiceThis!());
}
