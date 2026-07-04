/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.types;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct DataSubjectId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct PersonalDataModelId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct DeletionRequestId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct BlockingRequestId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct LegalGroundId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct RetentionRuleId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ConsentRecordId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct DataRetrievalRequestId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct DataControllerId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct DataControllerGroupId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct BusinessContextId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct BusinessProcessId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct BusinessSubprocessId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct CorrectionRequestId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ArchiveRequestId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct DestructionRequestId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct PurposeRecordId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ConsentPurposeId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct RuleSetId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct InformationReportId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct AnonymizationConfigId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}