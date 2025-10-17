/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.style;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

class DH5Style : DH5Obj {
	mixin(H5This!("style"));
}
mixin(H5Short!"Style");
unittest {
    testH5Obj(H5Style, "style");
}

string toString(DH5Style[] someStyles) {
	return someStyles.map!(s => s.toString).join;
}
unittest {
    // assert([H5Style, H5Style].toString == "<style></style><style></style>");
}

DH5Style[] H5Styles(string[string][] someStyles...) { 
	return H5Styles(someStyles.dup); 
}

DH5Style[] H5Styles(string[string][] someStyles) { 
	return someStyles.map!(s => H5Style(s)).array;
}
