/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven port to the task provider systems (S/4HANA, SuccessFactors, custom REST …).
module uim.platform.task_center.ports.gateways.task_provider;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

/// What a gateway needs to reach a provider.
struct ProviderConnection {
  string name;
  ProviderType providerType;
  AuthenticationType authType;
  string endpointUrl;
  string authEndpointUrl;
  string clientId;
  string clientSecret;
}

/// A task as reported by a provider (tolerant: unknown values fall back).
struct ProviderTask {
  string externalId; /// required
  string title; /// required
  string description;
  string status; /// TaskStatus value, "" = open
  string priority; /// TaskPriority value, "" = definition default
  string category; /// TaskCategory value, "" = definition default
  string assignee;
  string creator;
  string dueDate; /// ISO date or timestamp
  string definitionName; /// matched against TaskDefinition.name
  string[] allowedActions;
  string customAttributes; /// JSON object text
}

interface ITaskProviderGateway {
  /// All open tasks of the provider. Throws on transport or format errors.
  ProviderTask[] fetchTasks(const ProviderConnection connection);
}
