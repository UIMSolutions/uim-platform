/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.embed;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <embed> HTML element is used to embed external content, such as multimedia files or interactive applications, into a web page. It allows for the inclusion of various types of media, such as audio, video, or plugins, providing a way to display rich content within the HTML document.
class DH5Embed : DH5Obj {
	mixin(H5This!"embed");
}
mixin(H5Short!"Embed");

unittest {
  testH5Obj(H5Embed, "embed");
}
