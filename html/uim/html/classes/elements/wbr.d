/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.wbr;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <wbr> HTML element represents a word break opportunity, which is a position within text where the browser may optionally break a line if needed for better text layout. It is used to suggest potential line break points in long words or phrases without forcing a break, allowing for improved readability and formatting of content, especially in responsive designs where space may be limited.	
class DH5Wbr : DH5Obj {
	mixin(H5This!"wbr");
}
mixin(H5Short!"Wbr");

unittest {
	testH5Obj(H5Wbr, "wbr");
}
