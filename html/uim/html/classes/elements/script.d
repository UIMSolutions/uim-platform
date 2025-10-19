/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.script;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <script> HTML element is used to embed or reference executable code within a web document. It is commonly used to include JavaScript code that adds interactivity, dynamic content, and functionality to web pages. The <script> element can either contain inline code directly within the element or reference an external script file using the "src" attribute. When the browser encounters a <script> element, it executes the code, allowing developers to manipulate the Document Object Model (DOM), handle events, and perform various tasks to enhance the user experience on the web page.
class DH5Script : DH5Obj {
	mixin(H5This!"script");

	override string renderJS(string[string] bindings = null) {
		return null;
	}
}
mixin(H5Short!"Script");

unittest {
  assert(H5Script == "<script></script>");
}

string toString(DH5Script[] scripts) {
	return scripts.map!(s => s.toString).join;
}
unittest {
    // assert([H5Script, H5Script].toString == "<script></script><script></script>");
}

DH5Script[] H5Scripts(string[string][] scripts...) { 
	return H5Scripts(scripts.dup); 
}

DH5Script[] H5Scripts(string[string][] scripts) { 
	return scripts.map!(s => H5Script(s)).array;
}
unittest {
		// TODO
}
