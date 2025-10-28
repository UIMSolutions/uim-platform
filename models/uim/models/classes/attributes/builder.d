/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.models.classes.attributes.builder;

import uim.models;

mixin(Version!"test_uim_models");

@safe:

static class DAttributeBuilder {
    // TODO
    public DAttribute build() {
        return new DAttribute(this);
    }
}
