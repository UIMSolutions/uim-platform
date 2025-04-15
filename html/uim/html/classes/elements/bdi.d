/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.bdi;

import uim.html;
@safe:

// Wrapper for bdi tag - tells the browser's bidirectional algorithm to treat the text it contains in isolation from its surrounding text.
class DH5Bdi : DH5Obj {
	mixin(H5This!"bdi");
}
mixin(H5Short!"Bdi");

unittest {
	testH5Obj(H5Bdi, "bdi");
}

