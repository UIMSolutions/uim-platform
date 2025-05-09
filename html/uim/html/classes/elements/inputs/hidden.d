﻿/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.inputs.hidden;

mixin(Version!("test_uim_html"));

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

/* 
 * The `DH5InputHidden` class represents an HTML input element of type "hidden".
 * It is a subclass of the `DH5Input` class, which provides the basic functionality for input elements.
 * The `mixin` statement is used to generate the HTML representation of the input element with the specified attributes.
 */
class DH5InputHidden : DH5Input {
  mixin(H5This!("Input", null, `["type":"hidden"]`, true));
}

<<<<<<< HEAD
unittest {
		// TODO Add Test
		}}
=======
mixin(H5Short!"InputHidden");

unittest {
  // TODO Add Test
}
>>>>>>> 8504c0aa77a642ca4cdfc94f5177dce259b60200
