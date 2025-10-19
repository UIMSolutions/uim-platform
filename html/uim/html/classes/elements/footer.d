/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.footer;

import uim.html;

mixin(Version!("test_uim_html"));
@safe:

// The <footer> HTML element represents a footer for its nearest sectioning content or sectioning root element. It typically contains information about the author, copyright data, links to related documents, or navigational elements. The footer is usually placed at the bottom of the page or section it belongs to.
class DH5Footer : DH5Obj {
  mixin(H5This!("Footer"));
}

mixin(H5Short!"Footer");

unittest {
  testH5Obj(H5Footer, "footer");
}
