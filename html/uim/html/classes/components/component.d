/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.components.component;

import uim.html;

@safe:

class DH5Component {
  this() {
    this.css(CSSMediaQueries);
  }

  mixin(OProperty!("DCSSMediaQueries", "css"));
  mixin(XString!("html"));
  mixin(XString!("js"));

  override string toString() {
    string result;
    result ~= "<style>" ~ _css.toString ~ "</style>";
    if (html.length > 0)
      result ~= html;
    if (js.length > 0)
      result ~= "<script>" ~ _js ~ "</script>";
    return "";
  }
}

auto H5Component() {
  return new DH5Component();
}

version (test_uim_html) {
  unittest {
    assert(H5Component);
  }
}
