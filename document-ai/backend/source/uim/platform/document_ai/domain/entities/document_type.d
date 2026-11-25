/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A document type (e.g. "Supplier invoice"): business category, default
/// extraction schema and the file types it accepts.
module uim.platform.document_ai.domain.entities.document_type;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

struct DocumentType {
  mixin TenantEntity!DocumentTypeId;

  ClientId clientId; /// optional: "" = shared by all clients
  string name;
  string description;
  DocumentCategory category = DocumentCategory.general;
  SchemaId defaultSchemaId; /// used when an upload names no schema
  string[] supportedFileTypes; /// FileType values; empty = all

  bool accepts(FileType t) const {
    return supportedFileTypes.length == 0 || supportedFileTypes.canFind(cast(string) t);
  }

  void validate() const {
    requireId(id.value, "Document type ID");
    requireText(name, "Name");
    requireMaxLength(name, 200, "Name");
    requireMaxLength(description, 2000, "Description");
    foreach (t; supportedFileTypes)
      parseDomainEnum!FileType(t, "file type");
  }
}

///
unittest {
  DocumentType t;
  t.id = DocumentTypeId("invoice");
  t.name = "Invoice";
  t.validate();
  assert(t.accepts(FileType.png));
  t.supportedFileTypes = ["pdf"];
  assert(t.accepts(FileType.pdf) && !t.accepts(FileType.png));
  t.supportedFileTypes = ["gif"];
  assert(failsWith(DaiErrorKind.invalid, () { t.validate(); }));
}
