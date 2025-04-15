﻿module uim.html.classes.elements.nav;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

// Wrapper for <nav>
// DH5Nav/H5Nav represents a section of a page whose purpose is to provide navigation links, either within the current document or to other documents.
class DH5Nav : DH5Obj {
	mixin(H5This!("nav"));
}
mixin(H5Short!"Nav");

unittest {
  testH5Obj(H5Nav, "nav");
}}
 