﻿/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.inputs.datetimelocal;

import uim.html;
@safe:

class DH5InputDATETIMELOCAL : DH5Input {
	mixin(H5This!("Input", null, `["type":"datetime-local"]`)); 
}
mixin(H5Short!"InputDATETIMELOCAL");

