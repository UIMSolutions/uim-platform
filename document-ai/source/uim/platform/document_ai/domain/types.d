/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.types;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
// ID aliases
struct DocumentId {
  mixin(IdTemplate);
}

struct SchemaId {
  mixin(IdTemplate);
}

struct TemplateId {
  mixin(IdTemplate);
}

struct DocumentTypeId {
  mixin(IdTemplate);
}

struct ExtractionResultId {
  mixin(IdTemplate);
}

struct EnrichmentDataId {
  mixin(IdTemplate);
}

struct TrainingJobId {
  mixin(IdTemplate);
}

struct ClientId {
  mixin(IdTemplate);
}

struct ResourceGroupId {
  mixin(IdTemplate);
}