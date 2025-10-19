/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.link;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <link> HTML element defines the relationship between the current document and an external resource. It is commonly used to link to external stylesheets, icons, and other resources that enhance the functionality and appearance of a web page. The <link> element is placed within the <head> section of an HTML document and typically includes attributes such as 'rel' (to specify the relationship type), 'href' (to provide the URL of the linked resource), and 'type' (to indicate the MIME type of the resource).
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
