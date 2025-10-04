/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.iframe;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

class DH5Iframe : DH5Obj {
  mixin(H5This!"iframe");
}

mixin(H5Short!"Iframe");

unittest {
<<<<<<< HEAD
    assert(H5Iframe == "<iframe></iframe>");
}}
=======
  assert(H5Iframe == "<iframe></iframe>");
}
>>>>>>> 8504c0aa77a642ca4cdfc94f5177dce259b60200
