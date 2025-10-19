/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.forms.helpers.functions;

import uim.forms;

mixin(Version!"test_uim_forms");

@safe:

bool isForm(Object obj) {
  if (obj is null) {
    return false;
  }
  return cast(IForm)(obj) !is null;
}
///
unittest {
  assert(isForm(new DForm()) == true);
  assert(isForm(null) == false);
  assert(isForm("not a form") == false);
}
