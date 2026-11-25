/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Evaluation of the training data of a schema: the accuracy is the share
/// of the values of confirmed documents that needed no correction.
module uim.platform.document_ai.domain.services.training_evaluator;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

struct TrainingData {
  int documents;
  int fields;
  int corrected;

  double accuracy() const {
    return fields == 0 ? 0 : cast(double)(fields - corrected) / fields;
  }
}

TrainingData evaluateTrainingData(const AiDocument[] confirmed, const ExtractedField[] fields) {
  TrainingData d;
  bool[string] ids;
  foreach (doc; confirmed)
    if (doc.status == DocumentStatus.confirmed) {
      ids[doc.id.value] = true;
      d.documents++;
    }
  foreach (f; fields)
    if (f.documentId.value in ids) {
      d.fields++;
      if (f.corrected)
        d.corrected++;
    }
  return d;
}

///
unittest {
  AiDocument a, b;
  a.id = DocumentId("a");
  a.status = DocumentStatus.confirmed;
  b.id = DocumentId("b");
  b.status = DocumentStatus.done;
  ExtractedField f1, f2, f3;
  f1.documentId = a.id;
  f2.documentId = a.id;
  f2.corrected = true;
  f3.documentId = b.id;
  auto d = evaluateTrainingData([a, b], [f1, f2, f3]);
  assert(d.documents == 1 && d.fields == 2 && d.corrected == 1 && d.accuracy == 0.5);
  assert(TrainingData.init.accuracy == 0);
}
