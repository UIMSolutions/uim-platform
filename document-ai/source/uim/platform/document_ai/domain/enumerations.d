/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.enumerations;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

// Document processing status
enum DocumentStatus {
  pending,
  processing,
  completed,
  failed,
  confirmed,
}
DocumentStatus toDocumentStatus(string value) {
    mixin(EnumSwitch("DocumentStatus", "DocumentStatus.pending"));
}
DocumentStatus[] toDocumentStatuses(string[] values) {
    return values.map!(v => toDocumentStatus(v)).array;
}
string toString(DocumentStatus status) {
    mixin(toEnumToStringSwitch("DocumentStatus"));
}

// Training job lifecycle
enum TrainingJobStatus {
  pending,
  running,
  completed,
  failed,
  cancelled,
}
TrainingJobStatus toTrainingJobStatus(string value) {
    mixin(EnumSwitch("TrainingJobStatus", "TrainingJobStatus.pending"));
}
TrainingJobStatus[] toTrainingJobStatuses(string[] values) {
    return values.map!(v => toTrainingJobStatus(v)).array;
}
string toString(TrainingJobStatus status) {
    return status.to!string;
}
string[] toStrings(TrainingJobStatus[] statuses) {
    return statuses.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("DocumentStatus"));

    assert("pending".toDocumentStatus == DocumentStatus.pending);
    assert("processing".toDocumentStatus == DocumentStatus.processing);
    assert("completed".toDocumentStatus == DocumentStatus.completed);
    assert("failed".toDocumentStatus == DocumentStatus.failed);
    assert("confirmed".toDocumentStatus == DocumentStatus.confirmed);
    assert("unknown".toDocumentStatus == DocumentStatus.pending); // default case

    assert(DocumentStatus.pending.toString == "pending");
    assert(DocumentStatus.processing.toString == "processing");
    assert(DocumentStatus.completed.toString == "completed");
    assert(DocumentStatus.failed.toString == "failed");
    assert(DocumentStatus.confirmed.toString == "confirmed");

    assert(["pending", "completed"].toDocumentStatus == [DocumentStatus.pending, DocumentStatus.completed]);
    assert([DocumentStatus.pending, DocumentStatus.completed].toStrings == ["pending", "completed"]);
}

// Extraction method used
enum ExtractionMethod {
  ml_model,
  generative_ai,
  template_based,
  hybrid,
}
ExtractionMethod toExtractionMethod(string value) {
    mixin(EnumSwitch("ExtractionMethod", "ExtractionMethod.ml_model"));
}
ExtractionMethod[] toExtractionMethods(string[] values) {
    return values.map!toExtractionMethod.array;
}
string toString(ExtractionMethod method) {
    return method.to!string;
}
string[] toStrings(ExtractionMethod[] methods) {
    return methods.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("ExtractionMethod"));

    assert("ml_model".toExtractionMethod == ExtractionMethod.ml_model);
    assert("generative_ai".toExtractionMethod == ExtractionMethod.generative_ai);
    assert("template_based".toExtractionMethod == ExtractionMethod.template_based);
    assert("hybrid".toExtractionMethod == ExtractionMethod.hybrid);
    assert("unknown".toExtractionMethod == ExtractionMethod.ml_model); // default case

    assert(ExtractionMethod.ml_model.toString == "ml_model");
    assert(ExtractionMethod.generative_ai.toString == "generative_ai");
    assert(ExtractionMethod.template_based.toString == "template_based");
    assert(ExtractionMethod.hybrid.toString == "hybrid");

    assert(["ml_model", "hybrid"].toExtractionMethods == [ExtractionMethod.ml_model, ExtractionMethod.hybrid]);
    assert([ExtractionMethod.ml_model, ExtractionMethod.hybrid].toStrings == ["ml_model", "hybrid"]);
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
DocumentCategory toDocumentCategory(string value) {
    mixin(EnumSwitch("DocumentCategory", "DocumentCategory.general"));
}
DocumentCategory[] toDocumentCategories(string[] values) {
    return values.map!(v => toDocumentCategory(v)).array;
}
string toString(DocumentCategory category) {
    return category.to!string;
}
string[] toStrings(DocumentCategory[] categories) {
    return categories.map!(c => toString(c)).array;
}
///
unittest {
    mixin(ShowTest!("DocumentCategory"));

    assert("invoice".toDocumentCategory == DocumentCategory.invoice);
    assert("purchase_order".toDocumentCategory == DocumentCategory.purchase_order);
    assert("payment_advice".toDocumentCategory == DocumentCategory.payment_advice);
    assert("delivery_note".toDocumentCategory == DocumentCategory.delivery_note);
    assert("credit_memo".toDocumentCategory == DocumentCategory.credit_memo);
    assert("bank_statement".toDocumentCategory == DocumentCategory.bank_statement);
    assert("receipt".toDocumentCategory == DocumentCategory.receipt);
    assert("contract".toDocumentCategory == DocumentCategory.contract);
    assert("customs_declaration".toDocumentCategory == DocumentCategory.customs_declaration);
    assert("bill_of_lading".toDocumentCategory == DocumentCategory.bill_of_lading);
    assert("letter_of_credit".toDocumentCategory == DocumentCategory.letter_of_credit);
    assert("general".toDocumentCategory == DocumentCategory.general);
    assert("unknown".toDocumentCategory == DocumentCategory.general); // default case

    assert(DocumentCategory.invoice.toString == "invoice");
    assert(DocumentCategory.purchase_order.toString == "purchase_order");
    assert(DocumentCategory.payment_advice.toString == "payment_advice");
    assert(DocumentCategory.delivery_note.toString == "delivery_note");
    assert(DocumentCategory.credit_memo.toString == "credit_memo");
    assert(DocumentCategory.bank_statement.toString == "bank_statement");
    assert(DocumentCategory.receipt.toString == "receipt");
    assert(DocumentCategory.contract.toString == "contract");
    assert(DocumentCategory.customs_declaration.toString == "customs_declaration");
    assert(DocumentCategory.bill_of_lading.toString == "bill_of_lading");
    assert(DocumentCategory.letter_of_credit.toString == "letter_of_credit");
    assert(DocumentCategory.general.toString == "general");

    assert(["invoice", "receipt"].toDocumentCategories == [DocumentCategory.invoice, DocumentCategory.receipt]);
    assert([DocumentCategory.invoice, DocumentCategory.receipt].toStrings == ["invoice", "receipt"]);
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
FieldValueType toFieldValueType(string value) {
    switch(value.toLower()) {
        case "string": return FieldValueType.string_;
        case "number": return FieldValueType.number_;
        case "date": return FieldValueType.date_;
        case "boolean": return FieldValueType.boolean_;
        case "currency": return FieldValueType.currency;
        case "address": return FieldValueType.address;
        case "line_items": return FieldValueType.line_items;
        default: return FieldValueType.string_; // default case
    }
}
FieldValueType[] toFieldValueType(string[] values)
    => values.map!toFieldValueType.array;

string toString(FieldValueType value) {
    switch(value) {
        case FieldValueType.string_: return "string";
        case FieldValueType.number_: return "number";
        case FieldValueType.date_: return "date";
        case FieldValueType.boolean_: return "boolean";
        case FieldValueType.currency: return "currency";
        case FieldValueType.address: return "address";
        case FieldValueType.line_items: return "line_items";
    }
}
string[] toStrings(FieldValueType[] values)
    => values.map!toString.array;

///
unittest {
    mixin(ShowTest!("FieldValueType"));

    assert("string".toFieldValueType == FieldValueType.string_);
    assert("number".toFieldValueType == FieldValueType.number_);
    assert("date".toFieldValueType == FieldValueType.date_);
    assert("boolean".toFieldValueType == FieldValueType.boolean_);
    assert("currency".toFieldValueType == FieldValueType.currency);
    assert("address".toFieldValueType == FieldValueType.address);
    assert("line_items".toFieldValueType == FieldValueType.line_items);
    assert("unknown".toFieldValueType == FieldValueType.string_); // default case

    assert(FieldValueType.string_.toString == "string");
    assert(FieldValueType.number_.toString == "number");
    assert(FieldValueType.date_.toString == "date");
    assert(FieldValueType.boolean_.toString == "boolean");
    assert(FieldValueType.currency.toString == "currency");
    assert(FieldValueType.address.toString == "address");
    assert(FieldValueType.line_items.toString == "line_items");

    assert(["string", "date"].toFieldValueType == [FieldValueType.string_, FieldValueType.date_]);
    assert([FieldValueType.string_, FieldValueType.date_].toStrings == ["string", "date"]);
}

// Confidence levels
enum ConfidenceLevel {
  high,
  medium,
  low,
}
ConfidenceLevel toConfidenceLevel(string value) {
    mixin(EnumSwitch!"ConfidenceLevel", "medium");
}

ConfidenceLevel[] toConfidenceLevels(string[] values)
    => values.map!toConfidenceLevel.array;

string toString(ConfidenceLevel value)
    => value.to!string;

string[] toStrings(ConfidenceLevel[] values)
    => values.map!toString.array;
    
///
unittest {
    mixin(ShowTest!("ConfidenceLevel"));

    assert("high".toConfidenceLevel == ConfidenceLevel.high);
    assert("medium".toConfidenceLevel == ConfidenceLevel.medium);
    assert("low".toConfidenceLevel == ConfidenceLevel.low);
    assert("unknown".toConfidenceLevel == ConfidenceLevel.medium); // default case

    assert(ConfidenceLevel.high.toString == "high");
    assert(ConfidenceLevel.medium.toString == "medium");
    assert(ConfidenceLevel.low.toString == "low");  

    assert(["high", "low"].toConfidenceLevels == [ConfidenceLevel.high, ConfidenceLevel.low]);
    assert([ConfidenceLevel.high, ConfidenceLevel.low].toStrings == ["high", "low"]);
}

// Enrichment match status
enum EnrichmentMatchStatus {
  matched,
  unmatched,
  ambiguous,
}

EnrichmentMatchStatus toEnrichmentMatchStatus(string value) {
    mixin(EnumSwitch("EnrichmentMatchStatus", "EnrichmentMatchStatus.unmatched"));
}   

EnrichmentMatchStatus[] toEnrichmentMatchStatuses(string[] values) {
    return values.map!(v => toEnrichmentMatchStatus(v)).array;
}

string toString(EnrichmentMatchStatus value) {
    return value.to!string;
}

string[] toStrings(EnrichmentMatchStatus[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("EnrichmentMatchStatus"));

    assert("matched".toEnrichmentMatchStatus == EnrichmentMatchStatus.matched);
    assert("unmatched".toEnrichmentMatchStatus == EnrichmentMatchStatus.unmatched);
    assert("ambiguous".toEnrichmentMatchStatus == EnrichmentMatchStatus.ambiguous);
    assert("unknown".toEnrichmentMatchStatus == EnrichmentMatchStatus.unmatched); // default case

    assert(EnrichmentMatchStatus.matched.toString == "matched");
    assert(EnrichmentMatchStatus.unmatched.toString == "unmatched");
    assert(EnrichmentMatchStatus.ambiguous.toString == "ambiguous");    
    
    assert(["matched", "ambiguous"].toEnrichmentMatchStatuses == [EnrichmentMatchStatus.matched, EnrichmentMatchStatus.ambiguous]);
    assert([EnrichmentMatchStatus.matched, EnrichmentMatchStatus.ambiguous].toStrings == ["matched", "ambiguous"]);
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
FileType toFileType(string value) {
    mixin(EnumSwitch("FileType", "FileType.pdf"));
}   

FileType[] toFileTypes(string[] values)
    => values.map!toFileType.array;

string toString(FileType value) {
    return value.to!string;
}
string[] toStrings(FileType[] values)
    => values.map!toString.array;

///
unittest {
    mixin(ShowTest!("FileType"));

    assert("pdf".toFileType == FileType.pdf);
    assert("png".toFileType == FileType.png);
    assert("jpeg".toFileType == FileType.jpeg);
    assert("tiff".toFileType == FileType.tiff);
    assert("xlsx".toFileType == FileType.xlsx);
    assert("docx".toFileType == FileType.docx);
    assert("unknown".toFileType == FileType.pdf); // default case

    assert(FileType.pdf.toString == "pdf");
    assert(FileType.png.toString == "png");
    assert(FileType.jpeg.toString == "jpeg");
    assert(FileType.tiff.toString == "tiff");
    assert(FileType.xlsx.toString == "xlsx");
    assert(FileType.docx.toString == "docx");   

    assert(["pdf", "docx"].toFileType == [FileType.pdf, FileType.docx]);
    assert([FileType.pdf, FileType.docx].toStrings == ["pdf", "docx"]);
}

// Schema status
enum SchemaStatus {
  active,
  inactive,
  draft,
}

SchemaStatus toSchemaStatus(string value) {
    mixin(EnumSwitch("SchemaStatus", "SchemaStatus.active"));
}

SchemaStatus[] toSchemaStatuses(string[] values)
    => values.map!toSchemaStatus.array;

string toString(SchemaStatus value)
    => value.to!string;

string[] toStrings(SchemaStatus[] values)
    => values.map!toString.array;

///
unittest {
    mixin(ShowTest!("SchemaStatus"));

    assert("active".toSchemaStatus == SchemaStatus.active);
    assert("inactive".toSchemaStatus == SchemaStatus.inactive);
    assert("draft".toSchemaStatus == SchemaStatus.draft);
    assert("unknown".toSchemaStatus == SchemaStatus.active); // default case

    assert(SchemaStatus.active.toString == "active");
    assert(SchemaStatus.inactive.toString == "inactive");
    assert(SchemaStatus.draft.toString == "draft");

    assert(["active", "draft"].toSchemaStatuses == [SchemaStatus.active, SchemaStatus.draft]);
    assert([SchemaStatus.active, SchemaStatus.draft].toStrings == ["active", "draft"]);
}

// Template status
enum TemplateStatus {
  active,
  inactive,
  draft,
}

TemplateStatus toTemplateStatus(string value) {
    mixin(EnumSwitch("TemplateStatus", "TemplateStatus.active"));
}

TemplateStatus[] toTemplateStatuses(string[] values)
    => values.map!toTemplateStatus.array;

string toString(TemplateStatus value)
    => value.to!string;

string[] toStrings(TemplateStatus[] values)
    => values.map!toString.array;
///
unittest {
    mixin(ShowTest!("TemplateStatus"));

    assert("active".toTemplateStatus == TemplateStatus.active);
    assert("inactive".toTemplateStatus == TemplateStatus.inactive);
    assert("draft".toTemplateStatus == TemplateStatus.draft);
    assert("unknown".toTemplateStatus == TemplateStatus.active); // default case    

    assert(TemplateStatus.active.toString == "active");
    assert(TemplateStatus.inactive.toString == "inactive");
    assert(TemplateStatus.draft.toString == "draft");   

    assert(["active", "draft"].toTemplateStatuses == [TemplateStatus.active, TemplateStatus.draft]);
    assert([TemplateStatus.active, TemplateStatus.draft].toStrings == ["active", "draft"]);
}