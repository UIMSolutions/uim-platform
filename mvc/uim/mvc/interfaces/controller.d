/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.mvc.interfaces.controller;

import uim.mvc;
mixin(Version!"test_uim_mvc");

@safe:
interface IController {
    void process(HTTPServerRequest request, HTTPServerResponse response);
}

