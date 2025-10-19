/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.meta;

import uim.html;

mixin(Version!("test_uim_html"));
@safe:

// The <meta> HTML element provides metadata about the HTML document. Metadata is information that describes various aspects of the document, such as its character encoding, author, description, keywords, and viewport settings. The <meta> element is typically placed within the <head> section of an HTML document and does not have a closing tag. It plays a crucial role in defining how the document is interpreted by browsers and search engines.
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

DH5Meta[] H5Metas(string[string][] metas...) {
  return H5Metas(metas.dup);
}

DH5Meta[] H5Metas(string[string][] metas) {
  DH5Meta[] results;
  foreach (meta; metas)
    results ~= H5Meta(meta);
  return results;
}

unittest {
  /// TODO
}
