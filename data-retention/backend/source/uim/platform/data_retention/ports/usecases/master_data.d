/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of the master data.
module uim.platform.data_retention.ports.usecases.master_data;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

/// Groups that are referenced by business purposes, data subjects or jobs cannot be deleted.
alias IManageApplicationGroups = IManageResource!(ApplicationGroup, ApplicationGroupId, ApplicationGroupInput);
/// Legal entities referenced by business purposes or data subjects cannot be deleted.
alias IManageLegalEntities = IManageResource!(LegalEntity, LegalEntityId, LegalEntityInput);
/// Roles referenced by business purposes or data subjects cannot be deleted.
alias IManageDataSubjectRoles = IManageResource!(DataSubjectRole, DataSubjectRoleId, DataSubjectRoleInput);
