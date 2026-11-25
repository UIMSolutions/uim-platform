/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A template: the layout of documents from one sender for a schema.
/// Template based extraction is more confident; sample documents are
/// confirmed documents the template was derived from.
module uim.platform.document_ai.domain.entities.template_;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

struct DocumentTemplate {
  mixin TenantEntity!TemplateId;

  ClientId clientId; /// optional
  SchemaId schemaId;
  DocumentTypeId documentTypeId; /// optional
  string name;
  string description;
  TemplateStatus status = TemplateStatus.draft;
  string senderName; /// e.g. the supplier the layout belongs to
  string[] sampleDocumentIds;

  bool isActive() const {
    return status == TemplateStatus.active;
  }

  void validate() const {
    requireId(id.value, "Template ID");
    requireText(schemaId.value, "Schema");
    requireText(name, "Name");
    requireMaxLength(name, 200, "Name");
    requireMaxLength(description, 2000, "Description");
    requireMaxLength(senderName, 200, "Sender");
    if (sampleDocumentIds.length > 50)
      throw DaiException.invalid("A template has at most 50 sample documents");
  }
}

///
unittest {
  DocumentTemplate t;
  t.id = TemplateId("acme");
  t.schemaId = SchemaId("inv");
  t.name = "ACME invoices";
  t.validate();
  assert(!t.isActive);
}
