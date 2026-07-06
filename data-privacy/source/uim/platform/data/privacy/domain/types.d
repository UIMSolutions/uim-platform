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
  mixin(IdTemplate);
}

struct PersonalDataModelId {
  mixin(IdTemplate);
}

struct DeletionRequestId {
  mixin(IdTemplate);
}

struct BlockingRequestId {
  mixin(IdTemplate);
}

struct LegalGroundId {
  mixin(IdTemplate);
}

struct RetentionRuleId {
  mixin(IdTemplate);
}

struct ConsentRecordId {
  mixin(IdTemplate);
}

struct DataRetrievalRequestId {
  mixin(IdTemplate);
}

struct DataControllerId {
  mixin(IdTemplate);
}

struct DataControllerGroupId {
  mixin(IdTemplate);
}

struct BusinessContextId {
  mixin(IdTemplate);
}

struct BusinessProcessId {
  mixin(IdTemplate);
}

struct BusinessSubprocessId {
  mixin(IdTemplate);
}

struct CorrectionRequestId {
  mixin(IdTemplate);
}

struct ArchiveRequestId {
  mixin(IdTemplate);
}

struct DestructionRequestId {
  mixin(IdTemplate);
}

struct PurposeRecordId {
  mixin(IdTemplate);
}

struct ConsentPurposeId {
  mixin(IdTemplate);
}

struct RuleSetId {
  mixin(IdTemplate);
}

struct InformationReportId {
  mixin(IdTemplate);
}

struct AnonymizationConfigId {
  mixin(IdTemplate);
}