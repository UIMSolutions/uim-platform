/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.content;

import uim.html;
@safe:

class DH5Content : DH5Obj {
	mixin(H5This!("content"));
}
mixin(H5Short!"Content");

unittest {
  testH5Obj(H5Content, "content");
}
