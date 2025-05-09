﻿/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.table;

mixin(Version!("test_uim_html"));

mixin(Version!("test_uim_html"));

import uim.html;

@safe:

class DH5Table : DH5Obj {
  mixin(H5This!"table");

<<<<<<< HEAD
	mixin(MyContent!("header", "H5Thead"));
	unittest {
		assert(H5Table.header, "<table><thead></thead></table>");
	}}

	mixin(MyContent!("body_", "H5Tbody"));
	unittest {
		assert(H5Table.body_, "<table><tbody></tbody></table>");
	}}

	mixin(MyContent!("footer", "H5Tfoot"));
	unittest {
		assert(H5Table.footer, "<table><tfoot></tfoot></table>");
	}}

	mixin(MyContent!("tr", "H5Tr"));
	unittest {
		assert(H5Table.tr, "<table><tr></tr></table>");
	}}

	mixin(MyContent!("row", "H5Tr"));
	unittest {
		assert(H5Table.row, "<table><tr></tr></table>");
	}}

	mixin(MyContent!("colgroup", "H5Colgroup"));
	unittest {
		assert(H5Table.colgroup, "<table><colgroup></colgroup></table>");
	}}

	mixin(MyContent!("caption", "H5Caption"));
	unittest {  
		assert(H5Table.caption, "<table><caption></caption></table>");
	}}
}
mixin(H5Short!"Table");
unittest {
    assert(H5Table == "<table></table>");
}}
=======
  mixin(MyContent!("header", "H5Thead"));
  unittest {
    assert(H5Table.header, "<table><thead></thead></table>");
  }
}

mixin(MyContent!("body_", "H5Tbody"));
unittest {
  assert(H5Table.body_, "<table><tbody></tbody></table>");
}

mixin(MyContent!("footer", "H5Tfoot"));
unittest {
  assert(H5Table.footer, "<table><tfoot></tfoot></table>");
}

mixin(MyContent!("tr", "H5Tr"));
unittest {
  assert(H5Table.tr, "<table><tr></tr></table>");
}

mixin(MyContent!("row", "H5Tr"));
unittest {
  assert(H5Table.row, "<table><tr></tr></table>");
}

mixin(MyContent!("colgroup", "H5Colgroup"));
unittest {
  assert(H5Table.colgroup, "<table><colgroup></colgroup></table>");
}

mixin(MyContent!("caption", "H5Caption"));
unittest {
  assert(H5Table.caption, "<table><caption></caption></table>");
}
}
mixin(H5Short!"Table");
unittest {
  assert(H5Table == "<table></table>");
}
>>>>>>> 8504c0aa77a642ca4cdfc94f5177dce259b60200
