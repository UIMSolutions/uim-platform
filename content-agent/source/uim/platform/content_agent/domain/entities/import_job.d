module uim.platform.content_agent.domain.entities.import_job;

import uim.platform.content_agent.domain.types;

/// An import operation that deploys a content package into the target landscape.
struct ImportJob
{
  ImportJobId id;
  TenantId tenantId;
  ContentPackageId packageId;
  TransportRequestId transportRequestId;
  ImportStatus status = ImportStatus.pending;
  string sourceFilePath;
  long importedSizeBytes;
  string createdBy;
  long startedAt;
  long completedAt;
  string errorMessage;
  string[] deployedItems;
}
