/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.progress;

import uim.html;

@safe:

// Das HTML-Element progress stellt einen Fortschrittsbalken dar, der den Fortschritt eines Vorgangs anzeigt, z.B. das Herunterladen einer Datei, das Abspielen eines Videos oder das Installieren einer Software.
class DH5Progress : DH5Obj {
  mixin(H5This!"progress");
}

mixin(H5Short!"Progress");

unittest {
  assert(H5Progress == "<progress></progress>");
}
