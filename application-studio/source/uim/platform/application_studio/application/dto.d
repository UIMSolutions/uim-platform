/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.dto;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

struct DevSpaceDTO {
    DevSpaceId devSpaceId;
    TenantId tenantId;
    string name;
    string description;
    string plan;
    DevSpaceTypeId devSpaceTypeId;
    string extensions;
    string owner;
    string region;
    string hibernateAfterDays;
    string memoryLimit;
    string diskLimit;
    UserId createdBy;
    UserId updatedBy;
}

struct DevSpaceTypeDTO {
    DevSpaceTypeId devSpaceTypeId;
    TenantId tenantId;
    string name;
    string description;
    string category;
    string predefinedExtensions;
    string supportedProjectTypes;
    string runtimeStack;
    string iconUrl;
    UserId createdBy;
    UserId updatedBy;
}

struct ExtensionDTO {
    ExtensionId extensionId;
    TenantId tenantId;
    string name;
    string description;
    string scope_;
    string status;
    string version_;
    string publisher;
    string category;
    string dependencies;
    string capabilities;
    string iconUrl;
    UserId createdBy;
    UserId updatedBy;
}

struct ProjectDTO {
    ProjectId projectId;
    TenantId tenantId;
    DevSpaceId devSpaceId;
    string name;
    string description;
    string projectType;
    ProjectTemplateId projectTemplateId;
    string rootPath;
    string gitRepositoryUrl;
    string gitBranch;
    string namespace_;
    UserId createdBy;
    UserId updatedBy;
}

struct ProjectTemplateDTO {
    ProjectTemplateId projectTemplateId;
    TenantId tenantId;
    string name;
    string description;
    string category;
    string targetProjectType;
    string version_;
    string requiredExtensions;
    string scaffoldConfig;
    string defaultFiles;
    string iconUrl;
    UserId createdBy;
    UserId updatedBy;
}

struct ServiceBindingDTO {
    ServiceBindingId serviceBindingId;
    TenantId tenantId;
    DevSpaceId devSpaceId;
    string name;
    string description;
    string providerType;
    string serviceUrl;
    string servicePath;
    string authType;
    string credentials;
    string systemAlias;
    UserId createdBy;
    UserId updatedBy;
}

struct RunConfigurationDTO {
    RunConfigurationId runConfigurationId;
    TenantId tenantId;
    ProjectId projectId;
    string name;
    string description;
    string mode;
    string entryPoint;
    string arguments;
    string environmentVars;
    string port;
    string debugPort;
    UserId createdBy;
    UserId updatedBy;
}

struct BuildConfigurationDTO {
    BuildConfigurationId buildConfigurationId;
    TenantId tenantId;
    ProjectId projectId;
    string name;
    string description;
    string deployTarget;
    string buildCommand;
    string deployCommand;
    string artifactPath;
    string mtaDescriptor;
    UserId createdBy;
    UserId updatedBy;
}
