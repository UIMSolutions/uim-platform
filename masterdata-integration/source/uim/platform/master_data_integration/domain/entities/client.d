/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.entities.client;

import uim.platform.master_data_integration.domain.types;

/// A connected client system participating in master data integration.
struct Client {
  ClientId id;
  TenantId tenantId;
  string name;
  string description;
  ClientType clientType = ClientType.sapS4Hana;
  ClientStatus status = ClientStatus.disconnected;

  // Connection details
  string systemUrl;
  string destinationName; // SAP BTP destination reference
  string communicationArrangement;

  // Capabilities
  MasterDataCategory[] supportedCategories;
  bool supportsInitialLoad;
  bool supportsDeltaReplication;
  bool supportsKeyMapping;

  // Authentication
  string authType; // "oauth2", "basic", "certificate"
  string clientIdRef; // Reference to credential store
  string certificateRef;

  // Metadata
  string createdBy;
  long createdAt;
  long updatedAt;
  long lastSyncAt;
}
