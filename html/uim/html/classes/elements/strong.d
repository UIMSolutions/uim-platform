/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.strong;

import uim.html;

mixin(Version!("test_uim_html"));
@safe:

// The <strong> HTML element is used to indicate that its contents have strong importance, seriousness, or urgency. By default, browsers typically render the text within a <strong> element in bold typeface to visually emphasize its significance. The <strong> element is often used to highlight key points, warnings, or important information within a document, helping to draw the reader's attention to critical content.
class DH5Strong : DH5Obj {
  mixin(H5This!"strong");
}

mixin(H5Short!"Strong");

unittest {
  assert(H5Strong == "<strong></strong>");
}
