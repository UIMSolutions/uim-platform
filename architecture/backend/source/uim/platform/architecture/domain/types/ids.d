/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Typed identifiers. TenantId and UserId come from uim-framework.
module uim.platform.architecture.domain.types.ids;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

struct BuildingBlockId {
  mixin(IdTemplate);
}

struct RelationshipId {
  mixin(IdTemplate);
}

/// A new server generated identifier (16 lowercase hex characters).
string newResourceId() @trusted {
  import std.uuid : randomUUID;
  import std.array : replace;

  return randomUUID().toString.replace("-", "")[0 .. 16];
}

/// Client supplied ids are stable, URL friendly references such as
/// "abb-crm" or "sbb-sales-cloud": 1-64 characters [a-z0-9._-], starting
/// with a letter or digit.
bool isValidResourceId(string id) pure {
  if (id.length == 0 || id.length > 64)
    return false;
  foreach (i, c; id) {
    auto alnum = (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9');
    if (!alnum && (i == 0 || (c != '-' && c != '_' && c != '.')))
      return false;
  }
  return true;
}

void requireResourceId(string id, string what) {
  if (!isValidResourceId(id))
    throw ArchitectureException.invalid(what ~ " '" ~ id
        ~ "' is invalid (1-64 characters a-z, 0-9, '.', '_', '-'; starting with a letter or digit)");
}

///
unittest {
  auto a = newResourceId();
  assert(a.length == 16 && a != newResourceId() && isValidResourceId(a));
  assert(isValidResourceId("abb-crm") && isValidResourceId("sbb.v2_x"));
  assert(!isValidResourceId("") && !isValidResourceId("-x") && !isValidResourceId("ABB") && !isValidResourceId("a b"));
  assert(BuildingBlockId("b").value == "b" && BuildingBlockId.init.isNull);
}
