/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Identifier rules of the AI API.
module uim.platform.ai_core.domain.services.identifiers;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

/// Resource group ids: 3-253 characters of [a-z0-9.-], starting and ending
/// alphanumeric (they become Kubernetes namespaces in SAP AI Core).
bool isValidResourceGroupId(string id) pure {
  if (id.length < 3 || id.length > 253)
    return false;
  foreach (i, c; id) {
    bool alnum = (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9');
    if (!alnum && ((c != '-' && c != '.') || i == 0 || i == id.length - 1))
      return false;
  }
  return true;
}

/// Ids of scenarios, executables and secrets: 1-64 characters of
/// [A-Za-z0-9._-], starting alphanumeric.
bool isValidResourceId(string id) pure {
  if (id.length == 0 || id.length > 64 || !isAlphaNum(id[0]))
    return false;
  foreach (c; id)
    if (!(isAlphaNum(c) || c == '-' || c == '_' || c == '.'))
      return false;
  return true;
}

void requireResourceGroupId(string id) {
  if (!isValidResourceGroupId(id))
    throw AiCoreException.invalid("Invalid resource group id '" ~ id
        ~ "' (3-253 characters a-z, 0-9, '-', '.'; must start and end alphanumeric)");
}

void requireResourceId(string id, string what) {
  if (!isValidResourceId(id))
    throw AiCoreException.invalid("Invalid " ~ what ~ " '" ~ id ~ "' (1-64 characters A-Z, a-z, 0-9, '.', '_', '-')");
}

///
unittest {
  assert(isValidResourceGroupId("default") && isValidResourceGroupId("team-a.prod"));
  assert(!isValidResourceGroupId("ab") && !isValidResourceGroupId("-abc") && !isValidResourceGroupId("Team"));
  assert(isValidResourceId("text-classifier_v2.1") && !isValidResourceId("_x") && !isValidResourceId("a~b"));
}
