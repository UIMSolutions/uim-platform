/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.meta;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

/* TODO: Add meta tags for charset, name, content, http-equiv, property, scheme, etc. */
class DH5Meta : DH5Obj {
	mixin(H5This!("meta", null, null, true));
}
mixin(H5Short!("Meta"));

unittest {
  assert(H5Meta == "<meta>");
}

string toString(DH5Meta[] metas) {
	return metas.map!(meta => meta.toString).join;
}
unittest {
    // assert([H5Meta, H5Meta].toString == "<meta><meta>");
}

DH5Meta[] H5Metas(string[string][] metas...) { return H5Metas(metas.dup); }
DH5Meta[] H5Metas(string[string][] metas) { 
	DH5Meta[] results;
	foreach(meta; metas) results ~= H5Meta(meta);
	return results; }
unittest {
	/// TODO
}
