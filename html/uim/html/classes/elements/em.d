/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.em;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <em> HTML element is used to emphasize text, typically rendering it in italics. It indicates that the content has stress emphasis, which can affect the meaning of a sentence.
class DH5Em: DH5Obj {
	mixin(H5This!"em");
}
mixin(H5Short!"Em");

unittest {
  testH5Obj(H5Em, "em");
}