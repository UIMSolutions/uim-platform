/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.dtos.specs;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

// Field names equal the entity's (see requests.d); defaults equal the entity defaults.

// ── Catalogue: dev space types, extensions, project templates ────────────────

struct DevSpaceTypeSpec {
  string name;
  string description;
  DevSpaceTypeCategory category = DevSpaceTypeCategory.custom;
  string[] predefinedExtensions;
  ProjectType[] supportedProjectTypes;
  string runtimeStack;
  string iconUrl;
}

alias CreateDevSpaceTypeRequest = CreateRootRequest!DevSpaceTypeSpec;
alias UpdateDevSpaceTypeRequest = UpdateRequest!(DevSpaceTypeId, DevSpaceTypeSpec);

struct ExtensionSpec {
  string name;
  string displayName;
  string description;
  ExtensionScope scope_ = ExtensionScope.additional;
  string version_ = "1.0.0";
  string publisher;
  string category;
  string[] dependencies;
  string[] capabilities;
  string iconUrl;
}

alias CreateExtensionRequest = CreateRootRequest!ExtensionSpec;
alias UpdateExtensionRequest = UpdateRequest!(ExtensionId, ExtensionSpec);

struct ProjectTemplateSpec {
  string name;
  string title;
  string description;
  TemplateCategory category = TemplateCategory.general;
  ProjectType targetProjectType = ProjectType.basic;
  string version_ = "1.0.0";
  string[] requiredExtensions;
  string[] scaffoldFiles;
  KeyValue[] parameters;
  string iconUrl;
}

alias CreateProjectTemplateRequest = CreateRootRequest!ProjectTemplateSpec;
alias UpdateProjectTemplateRequest = UpdateRequest!(ProjectTemplateId, ProjectTemplateSpec);

// ── Dev spaces ───────────────────────────────────────────────────────────────

struct DevSpaceSpec {
  string name;
  string description;
  DevSpaceTypeId devSpaceTypeId;
  DevSpacePlan plan = DevSpacePlan.standard;
  string owner;
  string region = "eu10";
  string[] extensions;
  int hibernateAfterDays = 7;
  int memoryLimitMb = 4096;
  int diskLimitGb = 10;
}

alias CreateDevSpaceRequest = CreateRootRequest!DevSpaceSpec;
alias UpdateDevSpaceRequest = UpdateRequest!(DevSpaceId, DevSpaceSpec);

// ── Projects and service bindings (parent = dev space) ───────────────────────

struct ProjectSpec {
  string name;
  string description;
  ProjectType projectType = ProjectType.basic;
  ProjectTemplateId templateId;
  string namespace_;
  string gitRepositoryUrl;
  string gitBranch = "main";
}

alias CreateProjectRequest = CreateRequest!(DevSpaceId, ProjectSpec);
alias UpdateProjectRequest = UpdateRequest!(ProjectId, ProjectSpec);

struct ServiceBindingSpec {
  string name;
  string description;
  ServiceProviderType providerType = ServiceProviderType.sapBtp;
  string systemAlias;
  string serviceUrl;
  string servicePath;
  BindingAuthType authType = BindingAuthType.noAuthentication;
  string user;
  string credentials;
}

alias CreateServiceBindingRequest = CreateRequest!(DevSpaceId, ServiceBindingSpec);
alias UpdateServiceBindingRequest = UpdateRequest!(ServiceBindingId, ServiceBindingSpec);

// ── Run and build configurations (parent = project) ──────────────────────────

struct RunConfigurationSpec {
  string name;
  string description;
  RunMode mode = RunMode.run;
  string entryPoint;
  string[] arguments;
  KeyValue[] environment;
  int port = 4004;
  int debugPort;
  string[] serviceBindings;
}

alias CreateRunConfigurationRequest = CreateRequest!(ProjectId, RunConfigurationSpec);
alias UpdateRunConfigurationRequest = UpdateRequest!(RunConfigurationId, RunConfigurationSpec);

struct BuildConfigurationSpec {
  string name;
  string description;
  DeployTarget deployTarget = DeployTarget.cloudFoundry;
  string buildCommand = "mbt build";
  string deployCommand;
  string mtaDescriptor;
  string artifactPath;
}

alias CreateBuildConfigurationRequest = CreateRequest!(ProjectId, BuildConfigurationSpec);
alias UpdateBuildConfigurationRequest = UpdateRequest!(BuildConfigurationId, BuildConfigurationSpec);
