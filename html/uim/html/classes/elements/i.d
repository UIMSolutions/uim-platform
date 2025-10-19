/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.i;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <i> HTML element represents a range of text that is set off from the normal text for some reason, such as idiomatic expressions, technical terms, or other text that requires emphasis without conveying extra importance. It is typically displayed in italics by default.
class DH5I : DH5Obj {
	mixin(H5This!"I");
}
mixin(H5Short!"I");

unittest {
  testH5Obj(H5I, "i");
}    
