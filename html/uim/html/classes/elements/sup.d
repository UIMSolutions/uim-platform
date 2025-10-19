/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.sup;

import uim.html;
@safe:

// The <sup> HTML element represents a superscript text, which is typically displayed as smaller text positioned slightly above the normal line of text. It is commonly used for footnotes, mathematical exponents, and other annotations that require a raised position relative to the surrounding text. The <sup> element helps improve the readability and clarity of content by visually distinguishing superscripted information from the main body of text.
class DH5Sup : DH5Obj {
	mixin(H5This!"sup");
}
mixin(H5Short!"Sup");

unittest {
    assert(H5Sup == "<sup></sup>");
}
