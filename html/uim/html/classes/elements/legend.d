/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.legend;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <legend> HTML element represents a caption for the content of its parent <fieldset> element. It is used to provide a title or description for a group of related form controls, enhancing the accessibility and organization of forms. The <legend> element is typically displayed at the top of the fieldset, and it helps users understand the purpose of the grouped controls within the form.
class DH5Legend : DH5Obj {
	mixin(H5This!"legend");
}
mixin(H5Short!"Legend");

unittest {
  testH5Obj(H5Legend, "legend");
}
