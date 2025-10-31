/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.nav;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <nav> HTML element represents a section of a page that links to other pages or to parts within the page: a section with navigation links. It is intended to be used for major navigational blocks such as primary site navigation, table of contents, or other significant groups of links that help users navigate through the content of a website or application.
class DH5Nav : DH5Obj {
	mixin(H5This!("nav"));
}
mixin(H5Short!"Nav");

unittest {
  testH5Obj(H5Nav, "nav");
}
 