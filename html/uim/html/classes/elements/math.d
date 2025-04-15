/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.math;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

// This module defines the Math element in HTML5.
// The MathML element is used to include mathematical notation in HTML documents.
class DH5Math : DH5Obj {
  mixin(H5This!"math");
}

mixin(H5Short!"Math");

unittest {
  testH5Obj(H5Math, "math");
}
