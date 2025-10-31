/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.map;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <map> HTML element is used to define an image map, which is a clickable area within an image that can link to different destinations. The <map> element contains one or more <area> elements that specify the coordinates and shapes of the clickable regions, as well as the URLs they link to. Image maps are useful for creating interactive images where different parts of the image can lead to different web pages or actions.
class DH5Map : DH5Obj {
	mixin(H5This!("map"));
}
mixin(H5Short!"Map");

unittest {
    testH5Obj(H5Map, "map");
}
