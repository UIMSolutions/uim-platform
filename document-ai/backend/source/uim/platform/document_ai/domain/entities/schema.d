/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// An extraction schema: the header fields and line item fields to extract
/// from documents of a type. Fields can change while the schema is a
/// draft; an active schema is frozen and used for extraction.
module uim.platform.document_ai.domain.entities.schema;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

struct Schema {
  mixin TenantEntity!SchemaId;

  ClientId clientId; /// optional
  DocumentTypeId documentTypeId; /// optional
  string name;
  string description;
  DocumentCategory category = DocumentCategory.general;
  SchemaStatus status = SchemaStatus.draft;
  string[] supportedLanguages; /// ISO 639-1 codes; empty = all
  int version_ = 1;
  SchemaId basedOnId; /// the schema this one was copied from
  long activatedAt;

  bool isDraft() const {
    return status == SchemaStatus.draft;
  }

  bool isActive() const {
    return status == SchemaStatus.active;
  }

  bool supportsLanguage(string language) const {
    import std.uni : icmp;

    return supportedLanguages.length == 0 || language.length == 0
      || supportedLanguages.canFind!(l => icmp(l, language) == 0);
  }

  void activate(long fieldCount, long headerFieldCount, long now) {
    if (status == SchemaStatus.active)
      throw DaiException.ruleViolation("Schema '" ~ id.value ~ "' is already active");
    if (headerFieldCount == 0)
      throw DaiException.ruleViolation("Schema '" ~ id.value ~ "' needs at least one header field to be activated");
    status = SchemaStatus.active;
    activatedAt = now;
  }

  void deprecate() {
    if (status != SchemaStatus.active)
      throw DaiException.ruleViolation("Only active schemas can be deprecated (schema '" ~ id.value ~ "' is "
          ~ cast(string) status ~ ")");
    status = SchemaStatus.deprecated_;
  }

  void validate() const {
    requireId(id.value, "Schema ID");
    requireText(name, "Name");
    requireMaxLength(name, 200, "Name");
    requireMaxLength(description, 2000, "Description");
    requireRange(version_, 1, 10_000, "Version");
    foreach (l; supportedLanguages)
      if (l.length < 2 || l.length > 8)
        throw DaiException.invalid("Language '" ~ l ~ "' is not an ISO 639 code");
  }
}

///
unittest {
  Schema s;
  s.id = SchemaId("inv");
  s.name = "Invoice";
  s.validate();
  assert(failsWith(DaiErrorKind.ruleViolation, () { s.activate(2, 0, 1); }));
  s.activate(2, 1, 5);
  assert(s.isActive && s.activatedAt == 5);
  assert(failsWith(DaiErrorKind.ruleViolation, () { s.activate(2, 1, 6); }));
  s.deprecate();
  assert(s.status == SchemaStatus.deprecated_);
  s.supportedLanguages = ["en", "de"];
  assert(s.supportsLanguage("DE") && !s.supportsLanguage("fr") && s.supportsLanguage(""));
}
