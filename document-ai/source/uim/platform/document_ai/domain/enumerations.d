/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.enumerations;

import uim.platform.document_ai;

// mixin(ShowModule!());

@safe:

// Document processing status
enum DocumentStatus {
  pending,
  processing,
  completed,
  failed,
  confirmed,
}
DocumentStatus toDocumentStatus(string s) {
    const map = [
        "pending": DocumentStatus.pending,
        "processing": DocumentStatus.processing,
        "completed": DocumentStatus.completed,
        "failed": DocumentStatus.failed,
        "confirmed": DocumentStatus.confirmed
    ];
    return map.get(s, DocumentStatus.pending);
}

// Training job lifecycle
enum TrainingJobStatus {
  pending,
  running,
  completed,
  failed,
  cancelled,
}
TrainingJobStatus toTrainingJobStatus(string s) {
    const map = [
        "pending": TrainingJobStatus.pending,
        "running": TrainingJobStatus.running,
        "completed": TrainingJobStatus.completed,
        "failed": TrainingJobStatus.failed,
        "cancelled": TrainingJobStatus.cancelled
    ];
    return map.get(s, TrainingJobStatus.pending);
}

// Extraction method used
enum ExtractionMethod {
  ml_model,
  generative_ai,
  template_based,
  hybrid,
}
ExtractionMethod toExtractionMethod(string s) {
    const map = [
        "ml_model": ExtractionMethod.ml_model,
        "generative_ai": ExtractionMethod.generative_ai,
        "template_based": ExtractionMethod.template_based,
        "hybrid": ExtractionMethod.hybrid
    ];
    return map.get(s, ExtractionMethod.ml_model);
}

// Document categories
enum DocumentCategory {
  invoice,
  purchase_order,
  payment_advice,
  delivery_note,
  credit_memo,
  bank_statement,
  receipt,
  contract,
  customs_declaration,
  bill_of_lading,
  letter_of_credit,
  general,
  custom,
}
DocumentCategory toDocumentCategory(string s) {
    const map = [
        "invoice": DocumentCategory.invoice,
        "purchase_order": DocumentCategory.purchase_order,
        "payment_advice": DocumentCategory.payment_advice,
        "delivery_note": DocumentCategory.delivery_note,
        "credit_memo": DocumentCategory.credit_memo,
        "bank_statement": DocumentCategory.bank_statement,
        "receipt": DocumentCategory.receipt,
        "contract": DocumentCategory.contract,
        "customs_declaration": DocumentCategory.customs_declaration,
        "bill_of_lading": DocumentCategory.bill_of_lading,
        "letter_of_credit": DocumentCategory.letter_of_credit,
        "general": DocumentCategory.general,
        "custom": DocumentCategory.custom
    ];
    return map.get(s, DocumentCategory.general);
}

// Field value types in schemas
enum FieldValueType {
  string_,
  number_,
  date_,
  boolean_,
  currency,
  address,
  line_items,
}
FieldValueType toFieldValueType(string s) {
    const map = [
        "string": FieldValueType.string_,
        "number": FieldValueType.number_,
        "date": FieldValueType.date_,
        "boolean": FieldValueType.boolean_,
        "currency": FieldValueType.currency,
        "address": FieldValueType.address,
        "line_items": FieldValueType.line_items
    ];
    return map.get(s, FieldValueType.string_);
}

// Confidence levels
enum ConfidenceLevel {
  high,
  medium,
  low,
}
ConfidenceLevel toConfidenceLevel(string s) {
    const map = [
        "high": ConfidenceLevel.high,
        "medium": ConfidenceLevel.medium,
        "low": ConfidenceLevel.low
    ];
    return map.get(s, ConfidenceLevel.medium);
}

// Enrichment match status
enum EnrichmentMatchStatus {
  matched,
  unmatched,
  ambiguous,
}
EnrichmentMatchStatus toEnrichmentMatchStatus(string s) {
    const map = [
        "matched": EnrichmentMatchStatus.matched,
        "unmatched": EnrichmentMatchStatus.unmatched,
        "ambiguous": EnrichmentMatchStatus.ambiguous
    ];
    return map.get(s, EnrichmentMatchStatus.unmatched);
}   

// File types supported
enum FileType {
  pdf,
  png,
  jpeg,
  tiff,
  xlsx,
  docx,
}
FileType toFileType(string s) {
    const map = [
        "pdf": FileType.pdf,
        "png": FileType.png,
        "jpeg": FileType.jpeg,
        "tiff": FileType.tiff,
        "xlsx": FileType.xlsx,
        "docx": FileType.docx
    ];
    return map.get(s, FileType.pdf);
}   

// Schema status
enum SchemaStatus {
  active,
  inactive,
  draft,
}
SchemaStatus toSchemaStatus(string s) {
    const map = [
        "active": SchemaStatus.active,
        "inactive": SchemaStatus.inactive,
        "draft": SchemaStatus.draft
    ];
    return map.get(s, SchemaStatus.active);
}

// Template status
enum TemplateStatus {
  active,
  inactive,
  draft,
}
TemplateStatus toTemplateStatus(string s) {
    const map = [
        "active": TemplateStatus.active,
        "inactive": TemplateStatus.inactive,
        "draft": TemplateStatus.draft
    ];
    return map.get(s, TemplateStatus.active);
}