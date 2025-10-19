/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.select;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <select> HTML element represents a control that provides a menu of options for the user to choose from. It is commonly used in forms to allow users to select one or more options from a predefined list. The <select> element can be configured to allow single or multiple selections, and it can include various attributes such as "selected" to indicate the default selected option, "options" to define the available choices, and "sorted" to specify whether the options should be displayed in a sorted order. The <select> element enhances user interaction by providing a convenient way to present and select options within a web page.
class DH5Select : DH5Obj {
	mixin(H5This!"select");

	mixin(TProperty!("string", "selected"));
	mixin(TProperty!("STRINGAA", "options"));
	mixin(TProperty!("bool", "sorted"));

	mixin(MyContent!("option", "H5Option"));

}
mixin(H5Short!"Select");

unittest {
	testH5Obj(H5Select, "select");
	
	assert(H5Select.option(["value":"aValue"]) == `<select><option value="aValue"></option></select>`);
	assert(H5Select.option(["value":"aValue"], "someContent") == `<select><option value="aValue">someContent</option></select>`);
}
