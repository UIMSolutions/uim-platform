/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.abbr;

import uim.html;
@safe:

// Wrapper for <abbr> - represents an abbreviation or acronym.
class DH5Abbr : DH5Obj {
	mixin(H5This!"abbr");
}
mixin(H5Short!"Abbr");

unittest {
	testH5Obj(H5Abbr, "abbr");
  
  assert(H5Abbr == `<abbr><abbr>`);
}
