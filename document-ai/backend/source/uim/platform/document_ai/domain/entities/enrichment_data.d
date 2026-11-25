/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// An enrichment record: master data (supplier, customer, employee, …) the
/// extracted header values are matched with. Attributes are key=value
/// pairs whose keys are field names of the schema (e.g. "senderName=ACME").
module uim.platform.document_ai.domain.entities.enrichment_data;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

struct EnrichmentData {
  mixin TenantEntity!EnrichmentDataId;

  ClientId clientId; /// optional
  DocumentTypeId documentTypeId; /// optional: "" = all document types
  EnrichmentSubtype subtype = EnrichmentSubtype.businessEntity;
  string externalId; /// key in the source system, e.g. the supplier number
  string name;
  string description;
  string[] attributes;

  /// Usable for a document of the client and type.
  bool appliesTo(ClientId client, DocumentTypeId type) const {
    return (clientId.isNull || clientId == client) && (documentTypeId.isNull || documentTypeId == type);
  }

  void validate() const {
    requireId(id.value, "Enrichment record ID");
    requireText(name, "Name");
    requireMaxLength(name, 200, "Name");
    requireMaxLength(externalId, 100, "External ID");
    requireMaxLength(description, 2000, "Description");
    if (attributes.length == 0)
      throw DaiException.invalid("An enrichment record needs at least one attribute (key=value)");
    if (attributes.length > 100)
      throw DaiException.invalid("An enrichment record has at most 100 attributes");
    normalizePairs(attributes, "Attribute");
  }
}

///
unittest {
  EnrichmentData e;
  e.id = EnrichmentDataId("acme");
  e.name = "ACME";
  assert(failsWith(DaiErrorKind.invalid, () { e.validate(); }));
  e.attributes = ["senderName=ACME Corp"];
  e.validate();
  assert(e.appliesTo(ClientId("c"), DocumentTypeId("t")));
  e.clientId = ClientId("c");
  assert(!e.appliesTo(ClientId("d"), DocumentTypeId("t")));
}
