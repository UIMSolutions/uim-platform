module uim.platform.abap_environment.application.dtos.transport_request;

import uim.platform.abap_environment;

// // mixin(ShowModule!());

@safe:

struct CreateTransportRequestRequest {
  TenantId tenantId;
  SystemInstanceId sourceSystemId;
  SystemInstanceId targetSystemId;

  string description;
  string owner;
  string transportType; // "workbench", "customizing", "transportOfCopies"
}

struct AddTransportTaskRequest {
  TransportRequestId transportRequestId;
  TenantId tenantId;
  
  string owner;
  string description;
  string[] objectList;
}