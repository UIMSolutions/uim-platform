/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.article;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

// Wrapper for <article> - represents a self-contained composition in a document, page, application, or site, 
// which is intended to be independently distributable or reusable (e.g., in syndication)
class DH5Article : DH5Obj {
  mixin(H5This!"article");
}

mixin(H5Short!"Article");

unittest {
	testH5Obj(H5Article, "article");
  assert(H5Article == `<article></article>`);
}
