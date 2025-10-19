/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.li;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <li> HTML element represents a list item within an ordered (<ol>) or unordered (<ul>) list. It is used to define individual items in a list structure, allowing for the organization and presentation of related content. Each <li> element can contain text, images, links, or other HTML elements, making it a versatile component for creating lists in web documents.
class DH5Li : DH5Obj {
	mixin(H5This!"li");
}
mixin(H5Short!"Li");

unittest {
  testH5Obj(H5Li, "li");
}}