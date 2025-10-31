/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.math;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <math> HTML element is used to embed mathematical expressions and notations within a web page. It is part of the MathML (Mathematical Markup Language) specification, which provides a way to represent complex mathematical formulas in a structured and semantically meaningful manner. The <math> element allows for the inclusion of various mathematical symbols, operators, and structures, enabling the display of equations and mathematical content in a way that is both visually appealing and accessible to assistive technologies.
class DH5Math : DH5Obj {
  mixin(H5This!"math");
}

mixin(H5Short!"Math");

unittest {
  testH5Obj(H5Math, "math");
}