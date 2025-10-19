modu/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.html.classes.elements.blockquote;

mixin(Version!"test_uim_html");

import uim.html;
@safe:

// The <blockquote> HTML element indicates that the enclosed text is an extended quotation.
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
