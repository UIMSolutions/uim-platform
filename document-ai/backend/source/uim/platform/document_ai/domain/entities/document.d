/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A document: an uploaded file, its processing state and the summary of
/// the extraction (the values are ExtractedField entities). The file
/// content itself is not stored by this service.
module uim.platform.document_ai.domain.entities.document;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

struct AiDocument {
  mixin TenantEntity!DocumentId;

  ClientId clientId; /// optional
  string fileName;
  FileType fileType = FileType.pdf;
  string mimeType;
  long fileSize; /// bytes
  int pageCount = 1;
  string language = "en";
  DocumentTypeId documentTypeId; /// optional
  SchemaId schemaId; /// resolved at upload (explicit or default of the type)
  TemplateId templateId; /// optional
  ExtractionMethod extractionMethod = ExtractionMethod.mlModel;
  DocumentStatus status = DocumentStatus.pending;
  string[] labels; /// key=value; "<field>=<value>" also guides the simulated extraction
  int attempts; /// extraction runs
  long processedAt;
  long confirmedAt;
  string confirmedBy;
  string errorMessage; /// failure or rejection reason
  double overallConfidence = 0;
  int extractedFieldCount;
  int lineItemCount;
  int lowConfidenceCount;
  int correctedFieldCount;
  EnrichmentDataId matchedEnrichmentId;
  MatchStatus matchStatus = MatchStatus.notChecked;
  double matchScore = 0;

  /// The extraction may run (again).
  bool canExtract() const {
    return status == DocumentStatus.pending || status == DocumentStatus.failed || status == DocumentStatus.done;
  }

  /// Values can be corrected.
  bool isReviewable() const {
    return status == DocumentStatus.done;
  }

  /// Done, but some values are below the confidence threshold.
  bool needsReview() const {
    return status == DocumentStatus.done && lowConfidenceCount > 0;
  }

  void confirm(string by, long now) {
    if (status != DocumentStatus.done)
      throw DaiException.ruleViolation("Only extracted documents (status done) can be confirmed; document '" ~ id.value
          ~ "' is " ~ cast(string) status);
    status = DocumentStatus.confirmed;
    confirmedAt = now;
    confirmedBy = by;
    errorMessage = "";
  }

  void reject(string reason, string by, long now) {
    if (status != DocumentStatus.done && status != DocumentStatus.failed)
      throw DaiException.ruleViolation("Only extracted or failed documents can be rejected; document '" ~ id.value
          ~ "' is " ~ cast(string) status);
    requireText(reason, "Reason");
    status = DocumentStatus.rejected;
    confirmedAt = now;
    confirmedBy = by;
    errorMessage = reason.strip;
  }

  void validate() const {
    requireId(id.value, "Document ID");
    requireText(fileName, "File name");
    requireMaxLength(fileName, 255, "File name");
    if (fileName.canFind('/') || fileName.canFind('\\'))
      throw DaiException.invalid("File name '" ~ fileName ~ "' must not contain a path");
    requireMaxLength(mimeType, 100, "MIME type");
    requireRange(fileSize, 0, 1L << 40, "File size");
    requireRange(pageCount, 1, 10_000, "Page count");
    requireText(language, "Language");
    requireMaxLength(language, 8, "Language");
    if (labels.length > 50)
      throw DaiException.invalid("A document has at most 50 labels");
    normalizePairs(labels, "Label");
  }
}

///
unittest {
  AiDocument d;
  d.id = DocumentId("d1");
  d.fileName = "invoice.pdf";
  d.validate();
  assert(d.canExtract && !d.isReviewable);
  assert(failsWith(DaiErrorKind.ruleViolation, () { d.confirm("ada", 1); }));
  d.status = DocumentStatus.done;
  d.lowConfidenceCount = 1;
  assert(d.needsReview);
  d.confirm("ada", 7);
  assert(d.status == DocumentStatus.confirmed && d.confirmedBy == "ada" && !d.canExtract);
  assert(failsWith(DaiErrorKind.ruleViolation, () { d.reject("x", "ada", 8); }));
  d.fileName = "../etc/passwd";
  assert(failsWith(DaiErrorKind.invalid, () { d.validate(); }));
}
