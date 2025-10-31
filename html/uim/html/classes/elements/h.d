/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.h;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <h1> to <h6> HTML elements represent six levels of section headings. <h1> defines the most important heading, while <h6> defines the least important. These elements are used to structure content hierarchically, making it easier for users and search engines to understand the organization of the document.
class DH5H1 : DH5Obj {
  mixin(H5This!("h1"));
}

mixin(H5Short!"H1");

class DH5H2 : DH5Obj {
  mixin(H5This!("h2"));
}

mixin(H5Short!"H2");

class DH5H3 : DH5Obj {
  mixin(H5This!("h3"));
}

mixin(H5Short!"H3");

class DH5H4 : DH5Obj {
  mixin(H5This!("h4"));
}

mixin(H5Short!"H4");

class DH5H5 : DH5Obj {
  mixin(H5This!("h5"));
}

mixin(H5Short!"H5");

class DH5H6 : DH5Obj {
  mixin(H5This!("h6"));
}

mixin(H5Short!"H6");

