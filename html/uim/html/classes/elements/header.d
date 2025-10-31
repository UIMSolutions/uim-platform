/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.header;

import uim.html;
@safe:

// The <header> HTML element represents a container for introductory content or a set of navigational links. It typically contains headings, logos, authorship information, and other elements that provide context for the content that follows. The <header> element is used to group related content at the beginning of a section or page, enhancing the overall structure and accessibility of the document.
class DH5Header : DH5Obj {
	mixin(H5This!("header"));
}
mixin(H5Short!"Header");

unittest {
  testH5Obj(H5Header, "header");
}
