/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.td;

import uim.html;
@safe:

// The <td> HTML element represents a standard data cell in an HTML table. It is used to define individual cells within a table row, containing data that is organized in a tabular format. The <td> element can hold various types of content, including text, images, links, and other HTML elements. It is typically used in conjunction with the <tr> (table row) and <table> elements to create structured tables for displaying information on web pages.
class DH5Td : DH5Obj {
	mixin(H5This!"td");
}
mixin(H5Short!"Td");

unittest {
  testH5Obj(H5Td, "td");
}
