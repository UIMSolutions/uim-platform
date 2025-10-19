/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.bdi;

mixin(Version!("test_uim_html"));

import uim.html;

@safe:

// The <bdi> HTML element stands for Bi-Directional Isolation. It tells the browser to treat the text it contains in isolation from its surrounding text, so that the directionality of the text does not affect the surrounding text and vice versa.
class DH5Bdi : DH5Obj {
  mixin(H5This!"bdi");
}

mixin(H5Short!"Bdi");

unittest {
  testH5Obj(H5Bdi, "bdi");
}
