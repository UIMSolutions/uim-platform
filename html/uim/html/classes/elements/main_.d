/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.main_;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <main> HTML element represents the dominant content of the <body> of a document. It is used to encapsulate the primary content that is unique to the document, excluding repeated elements such as sidebars, navigation links, and footers. The <main> element helps improve accessibility by allowing assistive technologies to quickly identify and navigate to the main content of a page.
class DH5Main : DH5Obj {
  mixin(H5This!("main"));
}

mixin(H5Short!"Main");

unittest {
  testH5Obj(H5Main, "main");
}