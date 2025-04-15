﻿module uim.html.classes.elements.pre;

import uim.html;
@safe:

/* Das Element pre erlaubt es, Text so darzustellen, wie er im Editor eingegeben wird, pre steht dabei für preformatted, also präformatiert, vorformatiert. 
 */
class DH5Pre : DH5Obj {
	mixin(H5This!("pre"));
}
mixin(H5Short!"Pre");

unittest {
    assert(H5Pre == "<pre></pre>");
}}
