/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.infrastructure.persistence.files;

// File-based persistence adapters for Private Link Service.
//
// Each repository serialises entities as newline-delimited JSON (NDJSON) to
// a file under the configured PRIVLINK_DATA_DIR directory:
//
//   <dataDir>/service-instances.ndjson
//   <dataDir>/private-endpoints.ndjson
//   <dataDir>/service-bindings.ndjson
//
// Strategy:
//   - On write: append record or rewrite the full file on update/delete.
//   - On read:  parse all records into an in-memory TenantRepository cache on
//     first access (lazy load), then delegate to MemoryXxxRepository.
//
// Usage:
//   Set PRIVLINK_DATA_DIR=/var/lib/private-link when running the service to
//   activate file-based persistence instead of pure in-memory storage.
//
// Classes to implement (not yet active — use memory repos in production):
//   FileServiceInstanceRepository  : MemoryServiceInstanceRepository
//   FilePrivateEndpointRepository  : MemoryPrivateEndpointRepository
//   FileServiceBindingRepository   : MemoryServiceBindingRepository
