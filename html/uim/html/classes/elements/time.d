/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.time;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

import std.datetime;

// Wrapper for <time> - represents a specific period in time. It may include the datetime attribute to translate dates into machine-readable format, allowing for better search engine results or custom features such as reminders.
class DH5Time : DH5Obj {
	mixin(H5This!"time");
	
	mixin(MyAttribute!"datetime");
	// 0 datetime(this O)(Date value) {
		// return datetime(value.toString);
	// }
}
mixin(H5Short!"Time");

unittest {
  testH5Obj(H5Time, "time");
}
