/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.domain.ports.repositories.data_records;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.data_record;

interface DataRecordRepository {
  DataRecord[] findByDataset(DatasetId datasettenantId, id tenantId);
  DataRecord* findById(DataRecordId tenantId, id tenantId);
  DataRecord[] findByStatus(DatasetId datasettenantId, id tenantId, RecordStatus status);
  long countByDataset(DatasetId datasettenantId, id tenantId);
  void save(DataRecord record);
  void update(DataRecord record);
  void remove(DataRecordId tenantId, id tenantId);
  void removeByDataset(DatasetId datasettenantId, id tenantId);
}
