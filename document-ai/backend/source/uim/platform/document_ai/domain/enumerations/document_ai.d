/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business enumerations and status values. All enumerations are string
/// valued: the value is what the APIs accept and return.
module uim.platform.document_ai.domain.enumerations.document_ai;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

/// Processing status of a document.
///   pending → done (extracted) → confirmed | rejected;  pending → failed → pending (reprocess)
enum DocumentStatus : string {
  pending = "pending", /// uploaded, waiting for the extraction
  done = "done", /// extracted; values can be reviewed and corrected
  failed = "failed", /// the extraction failed; reprocess it
  confirmed = "confirmed", /// a person confirmed the values (final, used for training)
  rejected = "rejected" /// a person rejected the document (final)
}

/// How the values of a document are extracted.
enum ExtractionMethod : string {
  mlModel = "mlModel", /// pre-trained machine learning model
  generativeAi = "generativeAi", /// large language model (schema driven)
  templateBased = "templateBased", /// positions of a template
  hybrid = "hybrid" /// model + template
}

/// Business category of a document type.
enum DocumentCategory : string {
  invoice = "invoice",
  purchaseOrder = "purchaseOrder",
  paymentAdvice = "paymentAdvice",
  deliveryNote = "deliveryNote",
  creditMemo = "creditMemo",
  bankStatement = "bankStatement",
  receipt = "receipt",
  contract = "contract",
  customsDeclaration = "customsDeclaration",
  billOfLading = "billOfLading",
  letterOfCredit = "letterOfCredit",
  general = "general",
  custom = "custom"
}

/// Type of an extracted value.
enum FieldValueType : string {
  text = "string",
  number = "number",
  date = "date",
  boolean = "boolean",
  currency = "currency", /// ISO 4217 code
  address = "address"
}

/// Where a field of a schema lives.
enum FieldScope : string {
  header = "header", /// once per document
  lineItem = "lineItem" /// once per line item (table row)
}

/// Lifecycle of an extraction schema.
enum SchemaStatus : string {
  draft = "draft", /// fields can change; not usable for extraction
  active = "active", /// usable; fields are frozen
  deprecated_ = "deprecated" /// no new documents; existing ones keep it
}

/// Lifecycle of a template.
enum TemplateStatus : string {
  draft = "draft",
  active = "active",
  inactive = "inactive"
}

/// Status of a model training job.
enum TrainingJobStatus : string {
  pending = "pending",
  running = "running",
  completed = "completed",
  failed = "failed",
  cancelled = "cancelled"
}

/// Result of matching a document against the enrichment data.
enum MatchStatus : string {
  notChecked = "notChecked",
  matched = "matched", /// score >= 0.8
  ambiguous = "ambiguous", /// score >= 0.4
  unmatched = "unmatched"
}

/// Kind of enrichment record (master data the extracted values are matched with).
enum EnrichmentSubtype : string {
  businessEntity = "businessEntity",
  supplier = "supplier",
  customer = "customer",
  employee = "employee",
  material = "material",
  custom = "custom"
}

/// Supported file types (by extension).
enum FileType : string {
  pdf = "pdf",
  png = "png",
  jpeg = "jpeg",
  tiff = "tiff",
  xlsx = "xlsx",
  docx = "docx"
}

/// Confidence bands of an extracted value (derived, see confidenceLevel).
enum ConfidenceLevel : string {
  high = "high",
  medium = "medium",
  low = "low"
}

/// True for final document states (no more changes).
bool isFinal(DocumentStatus s) pure {
  return s == DocumentStatus.confirmed || s == DocumentStatus.rejected;
}

/// True for training jobs that are not finished.
bool isOpen(TrainingJobStatus s) pure {
  return s == TrainingJobStatus.pending || s == TrainingJobStatus.running;
}

///
unittest {
  assert(isFinal(DocumentStatus.confirmed) && !isFinal(DocumentStatus.done));
  assert(isOpen(TrainingJobStatus.running) && !isOpen(TrainingJobStatus.cancelled));
}
