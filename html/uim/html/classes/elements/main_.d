/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.main_;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

// Wrapper for <main> - represents the dominant content of the <body> of a document.
class DH5Main : DH5Obj {
  mixin(H5This!("main"));
}

mixin(H5Short!"Main");

unittest {
  testH5Obj(H5Main, "main");
}
