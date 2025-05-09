﻿/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.link;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Link : DH5Obj {
  mixin(H5This!("link", null, null, true));

  O styleSheet(this O)(bool mode = true) {
    if (mode) {
      attribues.set("rel", "stylesheet");
    } else {
      if (isStyleSheet)
        attributes.removeKey("rel");
    }
    cast(o) this;
  }

  bool isStyleSheet() {
    return (attributes.get("rel", null) == "stylesheet");
  }

  O icon(this O)(bool mode = true) {
    if (mode) {
      attribues.set("rel", "icon");
    } else {
      if (isIcon)
        attributes.removeKey("rel");
    }
    cast(o) this;
  }

  bool isIcon() {
    return (attributes.get("rel", null) == "stylesheet");
  }
}

mixin(H5Short!("Link"));

unittest {
  assert(H5Link == "<link>");
}
