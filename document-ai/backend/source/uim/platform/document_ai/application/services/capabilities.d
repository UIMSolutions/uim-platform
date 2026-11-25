/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// What the service supports (GET <api>/capabilities): file types,
/// languages, categories, value types and extraction methods.
module uim.platform.document_ai.application.services.capabilities;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

enum string[] supportedLanguages = ["en", "de", "fr", "es", "it", "pt", "nl", "pl", "ja", "zh", "ko", "ar", "hi"];

Json capabilitiesJson(string extractionMode, const DaiPolicy policy) {
  Json texts(const string[] values) {
    auto a = Json.emptyArray;
    foreach (v; values)
      a ~= Json(v);
    return a;
  }

  auto j = Json.emptyObject;
  j["apiVersion"] = "v1";
  j["extractionEngine"] = extractionMode;
  j["extraction"] = true;
  j["lineItems"] = true;
  j["classification"] = true;
  j["enrichment"] = true;
  j["templates"] = true;
  j["training"] = true;
  j["dataFeedback"] = true;
  j["multiClient"] = true;
  j["minConfidence"] = policy.minConfidence;
  j["minTrainingDocuments"] = policy.minTrainingDocuments;
  j["fileTypes"] = texts(domainEnumValues!FileType);
  j["languages"] = texts(supportedLanguages);
  j["documentCategories"] = texts(domainEnumValues!DocumentCategory);
  j["valueTypes"] = texts(domainEnumValues!FieldValueType);
  j["fieldScopes"] = texts(domainEnumValues!FieldScope);
  j["extractionMethods"] = texts(domainEnumValues!ExtractionMethod);
  j["documentStatuses"] = texts(domainEnumValues!DocumentStatus);
  j["schemaStatuses"] = texts(domainEnumValues!SchemaStatus);
  j["templateStatuses"] = texts(domainEnumValues!TemplateStatus);
  j["trainingStatuses"] = texts(domainEnumValues!TrainingJobStatus);
  j["enrichmentSubtypes"] = texts(domainEnumValues!EnrichmentSubtype);
  j["matchStatuses"] = texts(domainEnumValues!MatchStatus);
  j["scopes"] = texts(knownScopes);
  return j;
}

///
unittest {
  auto j = capabilitiesJson("simulate", DaiPolicy.init);
  assert(j["fileTypes"].length == 6 && j["extractionEngine"].get!string == "simulate");
}
