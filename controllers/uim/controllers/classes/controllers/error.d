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