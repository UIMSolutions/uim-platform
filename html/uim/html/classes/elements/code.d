/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.code;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <code> HTML element is used to define a fragment of computer code. The content inside is typically displayed in a monospaced font.
class DH5Code : DH5Obj {
	mixin(H5This!"code");
}
mixin(H5Short!"Code");

unittest {
  testH5Obj(H5Code, "code");
}
