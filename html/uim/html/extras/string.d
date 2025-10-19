/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.extras.string;

import uim.html;
@safe:

// Additional element to handle string in DOM
class DH5String : DH5Obj {
	private string _content;
    this(string aContent) { _content = aContent; }
    override string toString() { return _content; }

    override string toPretty(int intendSpace = 0, int step = 2) {
		return _content.indent(intendSpace);
	}
}
auto H5String(string text) { return new DH5String(text); }
auto H5String(T)(T value) { return new DH5String(to!string(value)); }
