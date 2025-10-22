/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.tests.form;

import uim.views;

mixin(Version!("test_uim_views"));

@safe:

bool testForm(IForm form) {
    assert(form !is null, "Form is null");

    return true;
}