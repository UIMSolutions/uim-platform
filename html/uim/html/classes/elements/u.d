/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.u;

import uim.html;

mixin(Version!("test_uim_html"));
@safe:

// The <u> HTML element represents a span of text that should be stylistically different from normal text, typically rendered with an underline. It is often used to indicate non-emphatic text that has a specific meaning or context, such as proper names, technical terms, or other special phrases. The <u> element can enhance the readability and visual distinction of certain text segments within a web page.
class DH5U : DH5Obj {
  mixin(H5This!"u");
}

mixin(H5Short!"U");

unittest {
  testH5Obj(H5U, "u");
}
