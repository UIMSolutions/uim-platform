/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.ins;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <ins> HTML element represents a range of text that has been inserted into a document. It is typically displayed with an underline to indicate the addition. The <ins> element is often used in conjunction with the <del> element, which represents deleted text, to show changes made to a document.
class DH5Ins : DH5Obj {
	mixin(H5This!"ins");
}
mixin(H5Short!"Ins");

unittest {
    testH5Obj(H5Ins, "ins");
}
