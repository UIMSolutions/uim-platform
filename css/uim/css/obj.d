﻿/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.css.obj;

mixin(Version!("test_uim_css"));

import uim.css;
@safe:

class DCSSObj {
	this() { _init; }	 
	protected void _init() {}

	override string toString() {
		return null;
	}
}
auto CSSOBJ() { return new DCSSObj(); }

unittest {
	// TODO
}
