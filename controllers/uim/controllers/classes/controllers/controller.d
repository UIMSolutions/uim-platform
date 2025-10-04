/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.controllers.classes.controllers.controller;

import uim.controllers;
mixin(Version!"test_uim_controllers");

@safe:
class DController : UIMObject, IController {
    mixin(ControllerThis!());

    void process(HTTPServerRequest request, HTTPServerResponse response) {
    }
}
