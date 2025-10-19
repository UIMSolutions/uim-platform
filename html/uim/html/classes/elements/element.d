/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.element;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <element> HTML element is a generic container that can be used to represent any HTML element. It serves as a base class for other specific HTML elements, providing common functionality and structure.
class DH5Element : DH5Obj {
  mixin(H5This!"element");
}

mixin(H5Short!"Element");

unittest {
  testH5Obj(H5Element, "element");
}