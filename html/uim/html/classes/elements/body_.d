module uim.html.classes.elements.body_;

import uim.html;
@safe:

// The <body> HTML element represents the content of an HTML document. It contains all the contents of an HTML document, such as text, hyperlinks, images, tables, lists, etc.
class DH5Body : DH5Obj {
	mixin(H5This!("body"));

	O scripts(this O)(string[] links) { foreach(l; links) add(H5Script(["src":l])); return cast(O)this; }
	O script(this O, T...)(T values) { add(H5Script(values)); return cast(O)this; }
}
mixin(H5Short!"Body");

unittest {
	assert(H5Body);
	assert(H5Body == "<body></body>");
}}
