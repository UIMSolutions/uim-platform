/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.controllers.classes.controllers.error;

import uim.controllers;
mixin(Version!"test_uim_controllers");

@safe:

/**
 * Error Handling Controller
 * Controller used by ErrorHandler to render error views.
 */
class DErrorController : DController {
    mixin(ControllerThis!("Error"));
}