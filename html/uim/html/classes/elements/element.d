/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.element;

import uim.html;
@safe:

class DH5Element : DH5Obj {
  mixin(H5This!"element");
}

mixin(H5Short!"Element");

unittest {
  assert(H5Element, "element");
}
