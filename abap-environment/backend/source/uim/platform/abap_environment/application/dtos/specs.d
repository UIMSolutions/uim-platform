/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.dtos.specs;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

// ── System instances ─────────────────────────────────────────────────────────

struct SystemSpec {
  SubaccountId subaccountId;
  string name;
  string description;
  SystemPlan plan = SystemPlan.standard;
  string region = "eu10";
  string sapSystemId; /// "" = derived from the name
  string adminEmail;
  int abapRuntimeSize = 16;
  int hanaMemorySize = 64;
}

alias CreateSystemRequest = CreateRootRequest!SystemSpec;
alias UpdateSystemRequest = UpdateRequest!(SystemInstanceId, SystemSpec);

// ── Software components ──────────────────────────────────────────────────────

struct SoftwareComponentSpec {
  string name;
  string description;
  ComponentType componentType = ComponentType.development;
  string repositoryUrl;
  string branch = "main";
  BranchStrategy branchStrategy = BranchStrategy.main;
  string namespace;
  string softwareComponentVersion;
}

alias CreateSoftwareComponentRequest = CreateRequest!(SystemInstanceId, SoftwareComponentSpec);
alias UpdateSoftwareComponentRequest = UpdateRequest!(SoftwareComponentId, SoftwareComponentSpec);

// ── Communication arrangements ───────────────────────────────────────────────

struct CommunicationArrangementSpec {
  string name;
  string description;
  CommunicationScenarioId scenarioId;
  CommunicationDirection direction = CommunicationDirection.inbound;
  string communicationSystem;
  CommunicationAuthMethod authMethod = CommunicationAuthMethod.basicAuthentication;
  string communicationUser;
  string communicationPassword;
  string clientId;
  string clientSecret;
  string tokenEndpoint;
  string certificateId;
  CommunicationEndpoint[] inboundServices;
  CommunicationEndpoint[] outboundServices;
}

alias CreateCommunicationArrangementRequest = CreateRequest!(SystemInstanceId, CommunicationArrangementSpec);
alias UpdateCommunicationArrangementRequest = UpdateRequest!(CommunicationArrangementId, CommunicationArrangementSpec);

// ── Service bindings ─────────────────────────────────────────────────────────

struct ServiceBindingSpec {
  string name;
  string description;
  string serviceDefinition;
  BindingType bindingType = BindingType.odataV4Ui;
  string serviceVersion = "0001";
  ExposedEndpoint[] endpoints;
}

alias CreateServiceBindingRequest = CreateRequest!(SystemInstanceId, ServiceBindingSpec);
alias UpdateServiceBindingRequest = UpdateRequest!(ServiceBindingId, ServiceBindingSpec);

// ── Business users and roles ─────────────────────────────────────────────────

struct BusinessUserSpec {
  string name;
  string firstName;
  string lastName;
  string email;
  /// Business roles by id or name.
  string[] roles;
}

alias CreateBusinessUserRequest = CreateRequest!(SystemInstanceId, BusinessUserSpec);
alias UpdateBusinessUserRequest = UpdateRequest!(BusinessUserId, BusinessUserSpec);

struct BusinessRoleSpec {
  string name;
  string description;
  RoleType roleType = RoleType.unrestricted;
  string[] businessCatalogs;
  string[] restrictionTypes;
}

alias CreateBusinessRoleRequest = CreateRequest!(SystemInstanceId, BusinessRoleSpec);
alias UpdateBusinessRoleRequest = UpdateRequest!(BusinessRoleId, BusinessRoleSpec);

// ── Transport requests (parent = source system) ──────────────────────────────

struct TransportRequestSpec {
  string description;
  string owner;
  TransportType transportType = TransportType.workbench;
  SystemInstanceId targetSystemId;
}

alias CreateTransportRequestRequest = CreateRequest!(SystemInstanceId, TransportRequestSpec);
alias UpdateTransportRequestRequest = UpdateRequest!(TransportRequestId, TransportRequestSpec);

// ── Application jobs ─────────────────────────────────────────────────────────

struct ApplicationJobSpec {
  string name;
  string description;
  string jobTemplateName;
  JobFrequency frequency = JobFrequency.once;
  long scheduledAt;
  string cronExpression;
  bool active = true;
  KeyValue[] parameters;
}

alias CreateApplicationJobRequest = CreateRequest!(SystemInstanceId, ApplicationJobSpec);
alias UpdateApplicationJobRequest = UpdateRequest!(ApplicationJobId, ApplicationJobSpec);
