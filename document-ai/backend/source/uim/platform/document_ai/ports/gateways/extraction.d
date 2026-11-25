/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven port to the extraction engine (OCR + machine learning or a
/// large language model). The use case resolves schema, fields and
/// template; the engine returns raw values with confidences.
module uim.platform.document_ai.ports.gateways.extraction;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

struct ExtractionRequest {
  TenantId tenantId;
  AiDocument document;
  Schema schema;
  SchemaField[] fields; /// in sequence (header and line item fields)
  DocumentTemplate template_; /// isNull without a template
}

/// One extracted value (rowIndex 0 = header, 1.. = line item).
struct ExtractedValue {
  string name;
  FieldScope fieldScope = FieldScope.header;
  int rowIndex;
  string value;
  double confidence = 0;
  int page = 1;
  string coordinates;
}

struct ExtractionOutput {
  bool success;
  string message; /// error text, or a short note
  ExtractedValue[] values;
  int pageCount; /// detected pages (0 = keep the uploaded value)
  long durationMs;
}

interface IExtractionEngine {
  /// "simulate" | "http"
  string mode();
  /// Never throws: failures are results.
  ExtractionOutput extract(ExtractionRequest request);
}
