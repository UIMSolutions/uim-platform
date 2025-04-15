/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.img;

import uim.html;
@safe:

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
