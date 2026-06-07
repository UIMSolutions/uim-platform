/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.types;

import uim.platform.document_ai;

// mixin(ShowModule!());

@safe:
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

struct TrainingJobId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ClientId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ResourceGroupId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}