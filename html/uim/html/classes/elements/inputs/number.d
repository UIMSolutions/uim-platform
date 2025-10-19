/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.inputs.number;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

class DH5InputNUMBER : DH5Input {
  mixin(H5This!("Input", null, `["type":"number"]`, true));
}

<<<<<<< HEAD
unittest {
		// TODO Add Test
		}}
=======
mixin(H5Short!"InputNUMBER");

unittest {
  // TODO Add Test
}
>>>>>>> 8504c0aa77a642ca4cdfc94f5177dce259b60200
