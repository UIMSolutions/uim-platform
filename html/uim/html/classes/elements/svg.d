/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.svg;

import uim.html;

mixin(Version!("test_uim_html"));
@safe:

// The <svg> HTML element is a container for Scalable Vector Graphics (SVG) content. SVG is an XML-based vector image format that allows for the creation of graphics that can be scaled to different sizes without losing quality. The <svg> element can contain various shapes, paths, text, and images, making it a powerful tool for creating complex and interactive graphics on web pages. It is widely used for icons, illustrations, animations, and data visualizations due to its scalability and flexibility.
class DH5Svg : DH5Obj {
  mixin(H5This!"svg");
}

mixin(H5Short!"Svg");

unittest {
  assert(H5Svg == "<svg></svg>");
}
