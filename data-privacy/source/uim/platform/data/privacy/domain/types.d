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

  mixin DomainId;
}

struct PersonalDataModelId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct DeletionRequestId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct BlockingRequestId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct LegalGroundId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct RetentionRuleId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ConsentRecordId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct DataRetrievalRequestId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct DataControllerId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct DataControllerGroupId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct BusinessContextId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct BusinessProcessId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct BusinessSubprocessId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct CorrectionRequestId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ArchiveRequestId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct DestructionRequestId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct PurposeRecordId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ConsentPurposeId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct RuleSetId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct InformationReportId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct AnonymizationConfigId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}