/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.presentation.cli;

// CLI presentation layer for Private Link Service.
// Provides command-line commands for managing service instances,
// private endpoints and service bindings.
//
// Commands (MVC pattern):
//   Model  -> use cases from application layer
//   View   -> formatted text/table output
//   Controller -> command dispatch (privlink-cli)
//
// Example commands:
//   privlink-cli instance list   --tenant <tenantId>
//   privlink-cli instance create --tenant <tenantId> --name <name> --resource <resourceId> --provider azure
//   privlink-cli instance delete --tenant <tenantId> --id <id>
//   privlink-cli endpoint list   --tenant <tenantId>
//   privlink-cli endpoint approve --tenant <tenantId> --id <id> --provider-id <providerEpId>
//   privlink-cli binding create  --tenant <tenantId> --instance <instanceId> --app <appId>
//   privlink-cli binding delete  --tenant <tenantId> --id <bindingId>
