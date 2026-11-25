/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Typed identifiers and identifier rules. TenantId and UserId come from
/// uim-framework.
module uim.platform.document_ai.domain.types.ids;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

struct ClientId { mixin(IdTemplate); }
struct DocumentTypeId { mixin(IdTemplate); }
struct SchemaId { mixin(IdTemplate); }
struct SchemaFieldId { mixin(IdTemplate); }
struct TemplateId { mixin(IdTemplate); }
struct DocumentId { mixin(IdTemplate); }
struct ExtractedFieldId { mixin(IdTemplate); }
struct EnrichmentDataId { mixin(IdTemplate); }
struct TrainingJobId { mixin(IdTemplate); }
struct UserAccountId { mixin(IdTemplate); }

enum size_t maxIdLength = 64;

/// A new identifier for server generated resources: 16 lowercase hex
/// characters (short enough for URLs, logs and keys).
string newResourceId() @trusted {
  import std.uuid : randomUUID;
  import std.array : replace;

  return randomUUID().toString.replace("-", "")[0 .. 16];
}

/// [A-Za-z0-9] followed by up to 63 of [A-Za-z0-9._-].
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
    throw DaiException.invalid(what ~ " '" ~ id ~ "' is invalid (1-64 characters: letters, digits, '.', '_', '-'; "
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
  assert(DocumentId("d").value == "d" && DocumentId.init.isNull);
  assert(isValidId("c-1.a_b") && !isValidId("-a") && !isValidId("a~b") && !isValidId("a b") && !isValidId(""));
  assert(idOrNew("").length == 16 && idOrNew("my-id") == "my-id");
  assert(failsWith(DaiErrorKind.invalid, () { idOrNew("a/b"); }));
}
