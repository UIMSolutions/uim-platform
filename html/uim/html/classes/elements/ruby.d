/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.ruby;

import uim.html;
mixin(Version!("test_uim_html")); 
@safe:

// The <ruby> HTML element represents a ruby annotation, which is a short run of text alongside the base text,
// typically used in East Asian typography to show the pronunciation of Chinese characters.
class DH5Ruby : DH5Obj {
	mixin(H5This!"ruby");
}
mixin(H5Short!"Ruby");

unittest {
    testH5Obj(H5Ruby, "ruby");
}
