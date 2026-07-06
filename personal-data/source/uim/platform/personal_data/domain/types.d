/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.types;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

/// Domain ID types
struct DataSubjectId  {
    mixin(IdTemplate);
}
struct DataSubjectRequestId  {
    mixin(IdTemplate);
}
struct PersonalDataRecordId  {
    mixin(IdTemplate);
}
struct RegisteredApplicationId  {
    mixin(IdTemplate);
}
struct ProcessingPurposeId  {
    mixin(IdTemplate);
}
struct ConsentRecordId  {
    mixin(IdTemplate);
}
struct RetentionRuleId  {
    mixin(IdTemplate);
}
struct DataProcessingLogId  {
    mixin(IdTemplate);
}

