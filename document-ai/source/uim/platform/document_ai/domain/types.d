/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.types;

// ID aliases
alias DocumentId = string;
alias SchemaId = string;
alias TemplateId = string;
alias DocumentTypeId = string;
alias ExtractionResultId = string;
alias EnrichmentDataId = string;
alias TrainingJobId = string;
alias ClientId = string;
alias TenantId = string;
alias ResourceGroupId = string;

// Document processing status
enum DocumentStatus {
  pending,
  processing,
  completed,
  failed,
  confirmed,
}

// Training job lifecycle
enum TrainingJobStatus {
  pending,
  running,
  completed,
  failed,
  cancelled,
}

// Extraction method used
enum ExtractionMethod {
  ml_model,
  generative_ai,
  template_based,
  hybrid,
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

// Confidence levels
enum ConfidenceLevel {
  high,
  medium,
  low,
}

// Enrichment match status
enum EnrichmentMatchStatus {
  matched,
  unmatched,
  ambiguous,
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

// Schema status
enum SchemaStatus {
  active,
  inactive,
  draft,
}

// Template status
enum TemplateStatus {
  active,
  inactive,
  draft,
}
