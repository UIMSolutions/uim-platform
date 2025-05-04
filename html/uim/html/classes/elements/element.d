/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.element;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Element : DH5Obj {
  mixin(H5This!"element");
}

mixin(H5Short!"Element");

unittest {
<<<<<<< HEAD
	assert(H5Element, "element");
}}
=======
  assert(H5Element, "element");
}
>>>>>>> 8504c0aa77a642ca4cdfc94f5177dce259b60200
