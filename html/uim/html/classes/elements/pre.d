/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module
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
