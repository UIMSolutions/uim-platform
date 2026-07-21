/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.infrastructure.persistence.repositories.data_models;

import uim.platform.master_data_integration;

mixin(ShowModule!());

@safe:

class MemoryDataModelRepository : TenantRepository!(DataModel, DataModelId), DataModelRepository {

  // #region ByName
  /**
    * Checks if a data model with the specified name exists for the tenant.
    *
    * @param tenantId The ID of the tenant.
    * @param name The name of the data model to check for existence.
    * @return `true` if a data model with the specified name exists, `false` otherwise.
    */
  bool existsByName(TenantId tenantId, string name) {
    return findByTenant(tenantId).any!((e) => e.name == name);
  }

  /**
    * Finds a data model by its name for the specified tenant.
    *
    * @param tenantId The ID of the tenant.
    * @param name The name of the data model to find.
    * @return The data model with the specified name, or an initialized data model if not found.
    */
  DataModel findByName(TenantId tenantId, string name) {
    foreach (m; findByTenant(tenantId)) {
      if (m.name == name)
        return m;
    }
    return DataModel.init;
  }

  /**
    * Removes a data model by its name for the specified tenant.
    *
    * @param tenantId The ID of the tenant.
    * @param name The name of the data model to remove.
    */
  void removeByName(TenantId tenantId, string name) {
    remove(findByName(tenantId, name));
  }
  // #endregion ByName

  // #region ByCategory
  /**
    * Counts the number of data models with the specified category for the tenant.
    *
    * @param tenantId The ID of the tenant.
    * @param category The category to filter data models by.
    * @return The count of data models with the specified category.
    */
  size_t countByCategory(TenantId tenantId, MasterDataCategory category) {
    return findByCategory(tenantId, category).length;
  }

  /**
    * Filters a list of data models by the specified category.
    *
    * @param models The list of data models to filter.
    * @param category The category to filter data models by.
    * @return A filtered array of data models that belong to the specified category.
    */
  DataModel[] filterByCategory(DataModel[] models, MasterDataCategory category) {
    return models.filter!(e => e.category == category).array;
  }

  /**
    * Finds data models by their category for the specified tenant.
    *
    * @param tenantId The ID of the tenant.
    * @param category The category to filter data models by.
    * @return An array of data models that belong to the specified category.
    */
  DataModel[] findByCategory(TenantId tenantId, MasterDataCategory category) {
    return filterByCategory(findByTenant(tenantId), category);
  }

  /**
    * Removes data models by their category for the specified tenant.
    *
    * @param tenantId The ID of the tenant.
    * @param category The category to filter data models by for removal.
    */
  void removeByCategory(TenantId tenantId, MasterDataCategory category) {
    findByCategory(tenantId, category).each!(entity => remove(entity));
  }
  // #endregion ByCategory

}
