﻿/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.input;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Input : DH5Obj {
	mixin(H5This!("input", null, null, true));
	unittest {
		assert(H5Input == "<input>");
	}}

	mixin(MyAttribute!("type"))	;
	unittest {
		assert(H5Input.type("text") == `<input type="text">`);
	}}

	mixin(MyAttribute!("accept"));
	mixin(MyAttribute!("autoComplete"));
	mixin(MyAttribute!("autofocus"));
	mixin(MyAttribute!("capture"));
	mixin(MyAttribute!("checked"));
	mixin(MyAttribute!("disabled"));
	
	mixin(MyAttribute!("form"));
	mixin(MyAttribute!("formAction"));
	mixin(MyAttribute!("formEnctype"));
	mixin(MyAttribute!("formMethod"));
	mixin(MyAttribute!("formNoValidate"));
	mixin(MyAttribute!("formTarget"));
	
	mixin(MyAttribute!("height"));
	mixin(MyAttribute!("list"));
	mixin(MyAttribute!("maxLength"));
	mixin(MyAttribute!("min"));
	mixin(MyAttribute!("minLength"));
	mixin(MyAttribute!("multiple"));
	mixin(MyAttribute!("pattern"));
	mixin(MyAttribute!("placeHolder"));
	mixin(MyAttribute!("readOnly"));
	mixin(MyAttribute!("required"));
	
	mixin(MyAttribute!("selectionDirection"));
	mixin(MyAttribute!("selectionEnd"));
	mixin(MyAttribute!("selectionStart"));
	mixin(MyAttribute!("size"));
	mixin(MyAttribute!("src"));
	mixin(MyAttribute!("step"));
	mixin(MyAttribute!("value"));
	mixin(MyAttribute!("width"));
}
mixin(H5Short!("Input"));

unittest {
	/* mixin(testH5SingleAttributes!("H5Input", "input", 
    [	"accept", "autoComplete",
			"autofocus", "capture", "checked", "disabled", "form", "formAction", "formEnctype", "formMethod", "formNoValidate", "formTarget",
			"height", "list", "maxLength", "min", "minLength", "multiple", "pattern", "placeHolder", "readOnly", "required",
			"selectionDirection", "selectionEnd", "selectionStart", "size", "src", "step", "value", "width"])); */
}}
