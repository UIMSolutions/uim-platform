/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.entities.form;

import uim.platform.process_automation.domain.types;

struct FormFieldOption {
    string label;
    string value;
}

struct FormField {
    FormFieldId id;
    string name;
    string label;
    FieldType type;
    bool required;
    string defaultValue;
    string placeholder;
    string validationRegex;
    string helpText;
    int sortOrder;
    FormFieldOption[] options;
}

struct FormSection {
    FormSectionId id;
    string title;
    string description;
    int sortOrder;
    FormField[] fields;
}

struct Form {
    FormId id;
    TenantId tenantId;
    ProjectId projectId;
    string name;
    string description;
    FormStatus status;
    FormSection[] sections;
    string version_;
    string createdBy;
    string modifiedBy;
    long createdAt;
    long modifiedAt;
}
