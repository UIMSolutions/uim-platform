/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.object;

import uim.html;
mixin(Version!("test_uim_html"));

@safe:

// The <object> HTML element represents an external resource, which can be treated as an image, a nested browsing context, or a resource to be handled by a plugin. It is commonly used to embed multimedia content such as images, videos, audio files, PDFs, and interactive applications within a web page. The <object> element allows for greater flexibility and control over how the embedded content is displayed and interacted with compared to other embedding methods like <img> or <iframe>.
class DH5Object : DH5Obj {
  mixin(H5This!"object");
}

mixin(H5Short!"Object");

unittest {
  assert(H5Object == "<object></object>");
}
