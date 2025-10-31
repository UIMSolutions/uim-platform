/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.template_;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <template> HTML element is a mechanism for holding client-side content that is not to be rendered when a page is loaded but can be instantiated later on at runtime using JavaScript. It is used to declare fragments of HTML that can be cloned and inserted into the document as needed, allowing for dynamic content generation and manipulation. The content inside a <template> element is inert, meaning it does not affect the document until it is explicitly activated, making it useful for defining reusable components or structures in web applications.
class DH5Template : DH5Obj {
	mixin(H5This!"template");
}
mixin(H5Short!"Template");

unittest {
    assert(H5Template == "<template></template>");
}
