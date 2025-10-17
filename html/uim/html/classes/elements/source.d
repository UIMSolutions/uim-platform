/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.source;

import uim.html;
@safe:

// The <source> HTML element is used to specify multiple media resources for media elements, such as <video> and <audio>. It is an empty element that contains attributes only.
class DH5Source : DH5Obj {
	mixin(H5This!"source");
	
	mixin(MyAttribute!"sizes");
  mixin(MyAttribute!"src");
  mixin(MyAttribute!"srcset");
  mixin(MyAttribute!"type");
  mixin(MyAttribute!"media"); 
}
mixin(H5Short!"Source");

unittest {
	testH5Obj(H5Source, "source");
	mixin(testH5DoubleAttributes!("H5Source", "source", [
    "sizes", "src", "srcset", "type", "media"]));
}
