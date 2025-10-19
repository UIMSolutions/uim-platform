module uim.html.classes.elements.b;

@safe:
import uim.html;

// The <b> HTML element is used to draw attention to the element's contents without conveying any extra importance or emphasis.
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
