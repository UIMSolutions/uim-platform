/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of document processing and the review of extracted values.
module uim.platform.document_ai.ports.usecases.documents;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

interface IProcessDocuments : IManageResource!(AiDocument, DocumentId, DocumentInput) {
  /// Run the extraction of a pending, failed or done document (again).
  AiDocument extract(TenantId t, DocumentId id, UserId actor);
  /// Accept the (corrected) values; required values must be present.
  AiDocument confirm(TenantId t, DocumentId id, UserId actor);
  AiDocument reject(TenantId t, DocumentId id, string reason, UserId actor);
  /// Extract up to max pending documents (0 = all) — the background worker.
  ProcessingSummary processPending(TenantId t, UserId actor, size_t max = 0);
}

interface IReviewFields {
  ExtractedField get(TenantId t, ExtractedFieldId id);
  ExtractedField[] list(TenantId t);
  /// The values of a document: header fields, then line items by row.
  ExtractedField[] listOf(TenantId t, DocumentId document);
  /// Correct a value of a document in status done.
  ExtractedField correct(TenantId t, ExtractedFieldId id, string value, UserId actor);
}
