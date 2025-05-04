/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.meter;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

// Wrapper for <meter> - represents either a scalar value within a known range or a fractional value.
class DH5Meter : DH5Obj {
  mixin(H5This!"meter");
}

mixin(H5Short!"Meter");

unittest {
<<<<<<< HEAD
    testH5Obj(H5Meter, "meter");
}}
=======
  testH5Obj(H5Meter, "meter");
}
>>>>>>> 8504c0aa77a642ca4cdfc94f5177dce259b60200
