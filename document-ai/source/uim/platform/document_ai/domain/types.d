/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.types;

// ID aliases
struct DocumentId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct SchemaId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct TemplateId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct DocumentTypeId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ExtractionResultId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct EnrichmentDataId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct TrainingJobId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct ClientId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct TenantId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct ResourceGroupId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

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
