/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.meter;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <meter> HTML element represents a scalar measurement within a known range, or a fractional value; for example, disk usage, the relevance of a query result, or the fraction of a voting population that supports a particular candidate.
class DH5Meter : DH5Obj {
  mixin(H5This!"meter");
}

mixin(H5Short!"Meter");

unittest {
  testH5Obj(H5Meter, "meter");
}