/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.fieldset;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <fieldset> HTML element is used to group related elements within a form, typically for better organization and visual separation. It often includes a <legend> element to provide a caption or title for the grouped content.
class DH5Fieldset : DH5Obj {
	mixin(H5This!"fieldset");
}
mixin(H5Short!"Fieldset");

unittest {
  testH5Obj(H5Fieldset, "fieldset");
}
