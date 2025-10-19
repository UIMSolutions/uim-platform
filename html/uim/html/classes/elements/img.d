/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.img;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <img> HTML element is used to embed images in a web page. It is a self-closing tag that requires the 'src' attribute to specify the path to the image file. The <img> element can also include attributes such as 'alt' for alternative text, 'width' and 'height' for defining the dimensions of the image, and 'title' for providing additional information about the image. It is an essential element for adding visual content to web pages, enhancing user experience and engagement.
class DH5Img : DH5Obj {
	mixin(H5This!("img", null, null, true));
}
mixin(H5Short!("Img"));

unittest {
    assert(H5Img);
    assert(H5Img == "<img>");
}

class DH5Image : DH5Obj {
	mixin(H5This!("img", null, null, true));
}
mixin(H5Short!("Image"));

unittest {
    assert(H5Image == "<img>");
}
