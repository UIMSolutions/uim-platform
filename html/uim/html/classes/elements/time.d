/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.time;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

import std.datetime;

// The <time> HTML element represents a specific period in time. It can be used to encode dates, times, or both, and is often utilized for events, deadlines, or timestamps. The element can include a datetime attribute that provides a machine-readable format of the date and time, enhancing accessibility and interoperability with other systems. This allows browsers and assistive technologies to better understand and present temporal information to users.
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
