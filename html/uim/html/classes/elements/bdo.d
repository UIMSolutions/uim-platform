module uim.html.classes.elements.bdo;

import uim.html;
@safe:

// The <bdo> HTML element (short for "bidirectional override") is used to override the current text direction.
class DH5Bdo : DH5Obj {
	mixin(H5This!"bdo");
}
mixin(H5Short!"Bdo");

unittest {
  testH5Obj(H5Bdo, "bdo");
}
