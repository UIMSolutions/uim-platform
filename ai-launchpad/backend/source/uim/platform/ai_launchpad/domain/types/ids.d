/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Typed identifiers and identifier rules. TenantId, UserId and
/// ConnectionId come from uim-framework.
module uim.platform.ai_launchpad.domain.types.ids;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct WorkspaceId { mixin(IdTemplate); }
struct ResourceGroupId { mixin(IdTemplate); }
struct ScenarioId { mixin(IdTemplate); }
struct ConfigurationId { mixin(IdTemplate); }
struct ExecutionId { mixin(IdTemplate); }
struct DeploymentId { mixin(IdTemplate); }
struct ModelId { mixin(IdTemplate); }
struct DatasetId { mixin(IdTemplate); }
struct PromptCollectionId { mixin(IdTemplate); }
struct PromptId { mixin(IdTemplate); }
struct TileId { mixin(IdTemplate); }
struct RoleId { mixin(IdTemplate); }
struct UserAccountId { mixin(IdTemplate); }
struct LogEntryId { mixin(IdTemplate); }

enum size_t maxIdLength = 64;

/// A new identifier for server generated resources: 16 lowercase hex
/// characters (short enough for URLs, logs and keys).
string newResourceId() @trusted {
  import std.uuid : randomUUID;
  import std.array : replace;

  return randomUUID().toString.replace("-", "")[0 .. 16];
}

/// [A-Za-z0-9] followed by up to 63 of [A-Za-z0-9._-] (technical names
/// such as "default", "fraud-detection" or "gpt-4o" qualify).
bool isValidId(string id) pure {
  if (id.length == 0 || id.length > maxIdLength)
    return false;
  foreach (i, c; id) {
    auto alnum = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9');
    if (i == 0 && !alnum)
      return false;
    if (!alnum && c != '.' && c != '_' && c != '-')
      return false;
  }
  return true;
}

void requireId(string id, string what) {
  if (!isValidId(id))
    throw AilpException.invalid(what ~ " '" ~ id ~ "' is invalid (1-64 characters: letters, digits, '.', '_', '-'; "
        ~ "starting with a letter or digit)");
}

/// A requested id, or a generated one.
string idOrNew(string requested, string what = "ID") {
  auto id = requested.strip;
  if (id.length == 0)
    return newResourceId();
  requireId(id, what);
  return id;
}

///
unittest {
  auto a = newResourceId();
  assert(a.length == 16 && a != newResourceId());
  assert(WorkspaceId("ws").value == "ws" && PromptId.init.isNull);
  assert(isValidId("gpt-4o") && isValidId("v1.2_a") && !isValidId("-a") && !isValidId("a b") && !isValidId(""));
  assert(idOrNew("").length == 16 && idOrNew("my-id") == "my-id");
  assert(failsWith(AilpErrorKind.invalid, () { idOrNew("a/b"); }));
}
