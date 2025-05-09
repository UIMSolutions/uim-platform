﻿module uim.html.classes.elements.source;

import uim.html;
@safe:

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
}}
