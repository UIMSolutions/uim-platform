/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Resource keys. Everything below a resource group is addressed by the
/// pair (resource group, id) — the AI API sends the group in the
/// "AI-Resource-Group" header. Storage and OData use one composite key
/// "<resourceGroupId>~<id>"; '~' is not allowed inside either part.
module uim.platform.ai_core.domain.types.keys;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

enum char keySeparator = '~';

/// "<resourceGroupId>~<id>"
string resourceKey(string resourceGroupId, string id) pure {
  return resourceGroupId ~ keySeparator ~ id;
}

/// Split a composite key; false if it is not one.
bool splitResourceKey(string key, out string resourceGroupId, out string id) pure {
  auto pos = key.indexOf(keySeparator);
  if (pos <= 0 || pos == cast(ptrdiff_t) key.length - 1)
    return false;
  resourceGroupId = key[0 .. pos];
  id = key[pos + 1 .. $];
  return id.indexOf(keySeparator) < 0;
}

///
unittest {
  string rg, id;
  assert(resourceKey("default", "abc") == "default~abc");
  assert(splitResourceKey("default~abc", rg, id) && rg == "default" && id == "abc");
  assert(!splitResourceKey("abc", rg, id));
  assert(!splitResourceKey("~abc", rg, id));
  assert(!splitResourceKey("a~b~c", rg, id));
}
