/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.classes.contexts.tests.test;

import uim.views;
@safe:

bool testFormContext(IFormContext context) {
    assert(context !is null, "FormContext is null");
    
    return true;
}