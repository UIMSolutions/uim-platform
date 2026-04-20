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
    mixin TenantEntity!(DataSubjectId);
    
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

    Json toJson() const {
        return entityToJson
            .set("subjectType", subjectType.to!string)
            .set("status", status.to!string)
            .set("firstName", firstName)
            .set("lastName", lastName)
            .set("email", email)
            .set("phoneNumber", phoneNumber)
            .set("dateOfBirth", dateOfBirth)
            .set("nationality", nationality)
            .set("organizationName", organizationName)
            .set("organizationId", organizationId)
            .set("externalId", externalId)  
            .set("applicationIds", applicationIds); 
    }
}
