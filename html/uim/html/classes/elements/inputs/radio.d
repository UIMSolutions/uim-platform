﻿/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.inputs.radio;

mixin(Version!"test_uim_html");

mixin(Version!"test_uim_html");

import uim.html;

@safe:

// Radio input element
// https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/radio
// https://www.w3schools.com/tags/tag_input.asp
// https://www.w3schools.com/tags/tag_input_radio.asp
class DH5Radio : DH5Input {
  mixin(H5This!("Input", null, `["type":"radio"]`, true));
}

mixin(H5Short!"Radio");

unittest {
  // TODO Add Test
}
