/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.sub;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <sub> HTML element represents subscript text, which is typically displayed as smaller text positioned slightly below the normal line of text. It is commonly used in chemical formulas, mathematical expressions, and other contexts where characters need to be lowered relative to the surrounding text. The <sub> element helps improve the readability and clarity of content by visually distinguishing subscripted information from the main body of text.
class DH5Sub : DH5Obj {
	mixin(H5This!"sub");
}
mixin(H5Short!"Sub");

unittest {
  testH5Obj(H5Sub, "sub");
}
