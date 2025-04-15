module uim.html.classes.elements.blockquote;

mixin(Version!"test_uim_html");

import uim.html;
@safe:

import uim.html;
@safe:

/*
 * @class DH5Blockquote
 * @brief Blockquote element
 * 
 * This class represents a blockquote element in HTML5.
 * It is used to define a section that is quoted from another source.
 */ 
class DH5Blockquote : DH5Obj {
	mixin(H5This!"blockquote");

  // Cite = A URL that designates a source document or message for the information quoted. 
  // This attribute is intended to point to information explaining the context or the reference for the quote.
  mixin(MyAttribute!("cite"));

  unittest {
    assert(H5Blockquote.cite("/server/somewhere").cite == "/server/somewhere");
    assert(H5Blockquote.cite("/server/somewhere") == `<blockquote cite="/server/somewhere"></blockquote>`);
  }
}
mixin(H5Short!"Blockquote");

unittest {
  testH5Obj(H5Blockquote, "blockquote");
}
