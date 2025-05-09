﻿/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.dd;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

/* Dd-Elemente enthalten eine Beschreibung eines zu beschreibenden Ausdrucks in einer Beschreibungsliste (Dd = description list data) */
class DH5Dd : DH5Obj {
	mixin(H5This!"dd");
}
mixin(H5Short!"Dd");

unittest {
  testH5Obj(H5Dd, "dd");
}
