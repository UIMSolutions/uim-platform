/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.infrastructure.persistence.mongo;

// MongoDB persistence adapters for Private Link Service.
//
// Collections used (database: "private_link"):
//   service_instances   - ServiceInstance documents
//   private_endpoints   - PrivateEndpoint documents
//   service_bindings    - ServiceBinding documents
//
// Connection:
//   Set PRIVLINK_MONGO_URI=mongodb://user:pass@host:27017/private_link to
//   enable MongoDB-backed persistence. Falling back to in-memory when not set.
//
// Document mapping:
//   Each struct's toJson() output is stored as the document body.
//   The _id field maps to the entity's id.value string.
//   Tenant isolation is enforced by always including tenantId in queries.
//
// Indexes recommended:
//   service_instances:  { tenantId: 1, name: 1 }  (unique)
//   private_endpoints:  { tenantId: 1, serviceInstanceId: 1 }
//   service_bindings:   { tenantId: 1, serviceInstanceId: 1 }
//
// Classes to implement (not yet active — use memory repos in production):
//   MongoServiceInstanceRepository  : ServiceInstanceRepository
//   MongoPrivateEndpointRepository  : PrivateEndpointRepository
//   MongoServiceBindingRepository   : ServiceBindingRepository
