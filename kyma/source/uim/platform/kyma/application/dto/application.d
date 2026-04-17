/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.dto.application;
/* 
import uim.platform.kyma.domain.types; */
import uim.platform.kyma;

mixin(ShowModule!());

@safe:

struct RegisterApplicationRequest {
  KymaEnvironmentId environmentId;
  TenantId tenantId;
  string name;
  string description;
  string registrationType; // "api", "events", "apiAndEvents"
  string connectorUrl;
  AppApiEntryDto[] apis;
  AppEventEntryDto[] events;
  string[] boundNamespaces;
  string[string] labels;
  string createdBy;
}

struct UpdateApplicationRequest {
  string description;
  string connectorUrl;
  AppApiEntryDto[] apis;
  AppEventEntryDto[] events;
  string[] boundNamespaces;
  string[string] labels;
}

struct AppApiEntryDto {
  string name;
  string description;
  string targetUrl;
  string specUrl;
  string authType;
}

struct AppEventEntryDto {
  string name;
  string description;
  string version_;
}
