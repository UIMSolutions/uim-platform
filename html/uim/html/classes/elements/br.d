/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.br;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

// Wrapper for the br tag - produces a line break in text (carriage-return).
class DH5Br : DH5Obj {
	mixin(H5This!("br", null, null, true));
}
mixin(H5Short!("Br"));
alias Br = H5Br; // Shortcut of shortcut

unittest {
  assert(H5Br,"<br>");
}
