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

    Json toJson() const {
        return Json.emptyObject
            .set("label", label)
            .set("value", value);
    }
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

    Json toJson() const {
        auto j = Json.emptyObject
            .set("id", id.value)
            .set("name", name)
            .set("label", label)
            .set("type", type.toString())
            .set("required", required)
            .set("defaultValue", defaultValue)
            .set("placeholder", placeholder)
            .set("validationRegex", validationRegex)
            .set("helpText", helpText)
            .set("sortOrder", sortOrder)
            .set("options", options.map!(o => o.toJson()).array);

        return j;
    }
}

struct FormSection {
    FormSectionId id;
    string title;
    string description;
    int sortOrder;
    FormField[] fields;

    Json toJson() const {
        auto j = Json.emptyObject
            .set("id", id.value)
            .set("title", title)
            .set("description", description)
            .set("sortOrder", sortOrder)
            .set("fields", fields.map!(f => f.toJson()).array);

        return j;
    }
}

struct Form {
    mixin TenantEntity!(FormId);

    ProjectId projectId;
    string name;
    string description;
    FormStatus status;
    FormSection[] sections;
    string version_;

    Json toJson() const {
        auto j = entityToJson
            .set("projectId", projectId.value)
            .set("name", name)
            .set("description", description)
            .set("status", status.toString())
            .set("version", version_)
            .set("sections", sections.map!(s => s.toJson()).array);

        return j;
    }
}

