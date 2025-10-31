/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.exceptions.missinghelper;

import uim.views;
@safe:

// Used when a helper cannot be found.
class DMissingHelperException : DViewException {
    mixin(ExceptionThis!("MissingHelper"));

    override bool initialize(Json[string] initData = null) {
        if (!super.initialize(initData)) {
            return false;
        }

        messageTemplate("default", "Helper class `%s` could not be found.");

        return true;
    }
}

mixin(ExceptionCalls!("MissingHelper"));
