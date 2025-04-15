module uim.html.classes.elements.b;

@safe:
import uim.html;

// Wrapper for the <b> tag - specifies bold text.

/* 
 * @class DH5B
 * @brief Bold text element
 * 
 * This class represents the <b> HTML element, which is used to 
 * display text in bold. It is a simple wrapper around the 
 * DH5Obj class.
 */
class DH5B : DH5Obj {
  mixin(H5This!"b");
}
mixin(H5Short!"B");

unittest {
  auto element = new DH5B;
  assert(element == "<b></b>");
}

unittest {
  // testH5Obj(H5B, "b");
}
