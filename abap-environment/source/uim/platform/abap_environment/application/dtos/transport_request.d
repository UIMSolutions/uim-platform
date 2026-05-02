module uim.platform.abap_environment.application.dtos.transport_request;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

struct CreateTransportRequestRequest {
  TenantId tenantId;
  SystemInstanceId sourceSystemId;
  string targetSystemId;
  string description;
  string owner;
  string transportType; // "workbench", "customizing", "transportOfCopies"
}

struct AddTransportTaskRequest {
  string owner;
  string description;
  string[] objectList;
}