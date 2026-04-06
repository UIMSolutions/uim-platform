/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.entities.data_subject;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

struct DataSubject {
    DataSubjectId id;
    TenantId tenantId;
    DataSubjectType subjectType;
    DataSubjectStatus status;
    string firstName;
    string lastName;
    string email;
    string phoneNumber;
    string dateOfBirth;
    string nationality;
    string organizationName;
    string organizationId;
    string externalId;
    string[] applicationIds;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
