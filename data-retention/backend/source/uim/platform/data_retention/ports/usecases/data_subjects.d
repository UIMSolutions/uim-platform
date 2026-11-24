/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the data subjects. Every returned data subject carries
/// its current retention evaluation.
module uim.platform.data_retention.ports.usecases.data_subjects;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface IManageDataSubjects : IManageResource!(DataSubject, DataSubjectId, DataSubjectInput) {
  DataSubject block(TenantId t, DataSubjectId id, UserId actor);
  DataSubject setLegalHold(TenantId t, DataSubjectId id, bool legalHold, string reason, UserId actor);
  /// Data subjects of one application group (empty id = all).
  DataSubject[] listByApplicationGroup(TenantId t, ApplicationGroupId group);
}
