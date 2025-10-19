/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.p;

import uim.html;
mixin(Version!("test_uim_html"));

@safe:

class DH5P : DH5Obj {
  mixin(H5This!("P"));
}

mixin(H5Short!"P");

unittest {
<<<<<<< HEAD
    assert(H5P == "<p></p>");
}}
=======
  assert(H5P == "<p></p>");
}
>>>>>>> 8504c0aa77a642ca4cdfc94f5177dce259b60200
