/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.application.dto;

import uim.platform.build_apps;

// mixin(ShowModule!());

@safe:

struct ApplicationDTO {
    TenantId tenantId;
    ApplicationId applicationId;

    string name;
    string description;
    string appType;
    string version_;
    string iconUrl;
    string themeConfig;
    string globalVariables;
    string defaultLanguage;
    string supportedLanguages;
    string owner;
    UserId createdBy;
    UserId updatedBy;
}

struct PageDTO {
    PageId pageId;
    TenantId tenantId;
    ApplicationId applicationId;
    string name;
    string description;
    string pageType;
    string route;
    string layoutConfig;
    string componentTree;
    string styleOverrides;
    string pageVariables;
    int sortOrder;
    bool isStartPage;
    UserId createdBy;
    UserId updatedBy;
}

struct UIComponentDTO {
    UIComponentId uiComponentId;
    TenantId tenantId;
    ApplicationId applicationId;
    string name;
    string description;
    string category;
    string version_;
    string properties;
    string styleProperties;
    string eventBindings;
    string dataBindings;
    string childComponents;
    string iconUrl;
    string previewUrl;
    UserId createdBy;
    UserId updatedBy;
}

struct DataEntityDTO {
    DataEntityId dataEntityId;
    TenantId tenantId;
    ApplicationId applicationId;
    string name;
    string description;
    string fields;
    string primaryKey;
    string indexes;
    string validationRules;
    string defaultValues;
    string relations;
    UserId createdBy;
    UserId updatedBy;
}

struct DataConnectionDTO {
    DataConnectionId dataConnectionId;
    TenantId tenantId;
    ApplicationId applicationId;
    string name;
    string description;
    string connectionType;
    string authMethod;
    string baseUrl;
    string basePath;
    string credentials;
    string headers;
    string queryParams;
    string responseMapping;
    string destinationName;
    UserId createdBy;
    UserId updatedBy;
}

struct LogicFlowDTO {
    LogicFlowId logicFlowId;
    TenantId tenantId;
    ApplicationId applicationId;
    PageId pageId;
    string name;
    string description;
    string trigger;
    string triggerConfig;
    string nodes;
    string connections;
    string variables;
    string errorHandler;
    UserId createdBy;
    UserId updatedBy;
}

struct AppBuildDTO {
    AppBuildId appBuildId;
    TenantId tenantId;
    ApplicationId applicationId;
    string name;
    string description;
    string buildTarget;
    string version_;
    string buildConfig;
    string signingConfig;
    UserId createdBy;
    UserId updatedBy;
}

struct ProjectMemberDTO {
    string id;
    TenantId tenantId;
    string applicationId;
    UserId userId;
    string displayName;
    string email;
    string role;
    string permissions;
    UserId createdBy;
    UserId updatedBy;
}
