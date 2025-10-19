/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.hr;

import uim.html;
@safe:

// The <hr> HTML element represents a thematic break or a horizontal rule in a web page. It is typically used to separate content into distinct sections, providing a visual cue to users that there is a shift in topic or theme. The <hr> element is a self-closing tag and does not require a closing tag.
class DH5Hr : DH5Obj {
	mixin(H5This!"hr");
}
mixin(H5Short!"Hr");
alias Hr = H5Hr;

unittest {
  testH5Obj(H5Hr, "hr");
}
