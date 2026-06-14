/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.types;

import uim.platform.personal_data;

// mixin(ShowModule!());

@safe:

/// Domain ID types
struct DataSubjectId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct DataSubjectRequestId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct PersonalDataRecordId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct RegisteredApplicationId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct ProcessingPurposeId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct ConsentRecordId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct RetentionRuleId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct DataProcessingLogId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

