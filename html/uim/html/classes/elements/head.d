/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.head;

import uim.html;

@safe:

// The <head> HTML element is a container for metadata (data about data) and links to external resources for the document. It typically includes elements such as <title>, <meta>, <link>, <style>, and <script>, which provide information about the document's title, character set, stylesheets, and scripts, among other things. The content within the <head> element is not displayed directly on the webpage but is essential for defining the document's structure and behavior.
class DH5Head : DH5Obj {
protected:
  string _title;
public:
  mixin(H5This!("head"));

  DH5Head Meta(string[string] values) {
    this.add(H5Meta(values));
    return this;
  }

  DH5Head Base(string[string] values) {
    this.add(H5Base(values));
    return this;
  }

  DH5Head Link(string[string] values) {
    this.add(H5Link(values));
    return this;
  }

  DH5Head Link(string href, string media = "") {
    if (media)
      return Link([
        "rel": "stylesheet",
        "href": href,
        "type": "text/css",
        "media": media
      ]);
    else
      return Link(["rel": "stylesheet", "href": href, "type": "text/css"]);
  }

  DH5Head Title(string content = null) {
    this.add(H5Title(content));
    return this;
  }

  O scripts(this O)(string[] links) {
    foreach (l; links)
      add(H5Script(["src": l]));
    return cast(O)this;
  }

  O script(this O, T...)(T values) {
    add(H5Script(values));
    return cast(O)this;
  }
}

mixin(H5Short!"Head");

unittest {
  testH5Obj(H5Head, "head");
}
