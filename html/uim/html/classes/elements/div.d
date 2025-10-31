/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.div;

import uim.html;
@safe:

// The <div> HTML element is a generic container used to group together other HTML elements. It has no specific semantic meaning but is commonly used for styling and layout purposes, allowing developers to apply CSS styles or JavaScript functionality to a section of content.
class DH5Div : DH5Obj {
	mixin(H5This!"div");
}
mixin(H5Short!"Div");

unittest {
  assert(H5Div);
  assert(H5Div == `<div></div>`);

  testH5Obj(H5Div, "div");
  
	// mixin(testH5Double!("H5Div", "div", true));	
	// mixin(testH5DoubleClasses!("H5Div", "div", true));	
}
