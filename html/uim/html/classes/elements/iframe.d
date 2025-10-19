/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.iframe;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <iframe> HTML element represents a nested browsing context, effectively embedding another HTML page within the current page. It is commonly used to display external content, such as videos, maps, or other web pages, while maintaining the context of the parent document. The <iframe> element allows for seamless integration of diverse content sources into a single web page.
class DH5Iframe : DH5Obj {
  mixin(H5This!"iframe");
}

mixin(H5Short!"Iframe");

unittest {
  assert(H5Iframe == "<iframe></iframe>");
}
