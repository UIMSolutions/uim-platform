/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Results of batch processing and of the demo content.
module uim.platform.document_ai.application.dtos.processing;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

/// Outcome of a processing run over pending documents.
struct ProcessingSummary {
  long documents; /// pending documents looked at
  long extracted;
  long failed;
  string[] messages;

  void add(const ProcessingSummary o) {
    documents += o.documents;
    extracted += o.extracted;
    failed += o.failed;
    messages ~= o.messages;
  }
}

/// What the demo content created.
struct SeedResult {
  long clients;
  long documentTypes;
  long schemas;
  long schemaFields;
  long templates;
  long enrichmentRecords;
  long documents;
  long trainingJobs;
}
