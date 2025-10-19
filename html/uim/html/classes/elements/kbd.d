/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.kbd;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <kbd> HTML element represents a span of text to be entered by the user, typically displayed in a monospaced font to indicate keyboard input. It is commonly used to denote keyboard shortcuts, commands, or any text that the user is expected to type.
class DH5Kbd : DH5Obj {
	mixin(H5This!"kbd");
}
mixin(H5Short!"Kbd");

unittest {
  testH5Obj(H5Kbd, "kbd");
}
