/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.application.usecases.manage.information_reports;

import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
class ManageInformationReportsUseCase {
  private IInformationReportRepository repo;
  private IDataSubjectRepository subjectRepo;

  this(IInformationReportRepository repo, IDataSubjectRepository subjectRepo) {
    this.repo = repo;
    this.subjectRepo = subjectRepo;
  }

  UsecaseResult createReport(CreateInformationReportRequest req) {
    if (req.tenantId.isNull)
      return UsecaseResult(false, "", "Tenant ID is required");
    if (req.subjectId.isNull)
      return UsecaseResult(false, "", "Data subject ID is required");

    auto subject = subjectRepo.findById(req.tenantId, req.subjectId);
    if (subject.isNull)
      return UsecaseResult(false, "", "Data subject not found");

    auto r = InformationReport(req.tenantId);
    r.subjectId = req.subjectId;
    r.subjectRole = subject.subjectType;
    r.requestedBy = req.requestedBy;
    r.status = InformationReportStatus.requested;
    r.format = parseExportFormat(req.format);
    r.targetSystems = req.targetSystems;
    r.categories = req.categories.map!(c => c.toPersonalDataCategory).array;
    r.reason = req.reason;
    r.requestedAt = currentTimestamp;

    repo.save(r);
    return UsecaseResult(true, r.id.value, "");
  }

  InformationReport getReport(TenantId tenantId, InformationReportId id) {
    return repo.findById(tenantId, id);
  }

  InformationReport[] listReports(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  InformationReport[] listReports(TenantId tenantId, DataSubjectId subjectId) {
    return repo.findByDataSubject(tenantId, subjectId);
  }

  UsecaseResult updateStatus(UpdateInformationReportStatusRequest req) {
    auto r = repo.findById(req.tenantId, req.reportId);
    if (r.isNull)
      return UsecaseResult(false, "", "Information report not found");

    r.status = req.status.toInformationReportStatus;
    if (req.downloadUrl.length > 0)
      r.downloadUrl = req.downloadUrl;
    if (req.totalRecords > 0)
      r.totalRecords = req.totalRecords;
    if (req.status.toInformationReportStatus == InformationReportStatus.completed) {
      r.generatedAt = Clock.currStdTime();
      r.expiresAt = r.generatedAt + 7 * 24 * 60 * 60 * 10_000_000L; // 7 days
    }

    repo.update(r);
    return UsecaseResult(true, r.id.value, "");
  }

  UsecaseResult deleteReport(TenantId tenantId, InformationReportId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return UsecaseResult(false, "", "Information report not found");

    repo.remove(entity);
    return UsecaseResult(true, entity.id.value, "");
  }

  private ExportFormat parseExportFormat(string s) {
    switch (s) {
    case "json":
      return ExportFormat.json;
    case "xml":
      return ExportFormat.xml;
    case "csv":
      return ExportFormat.csv;
    default:
      return ExportFormat.pdf;
    }
  }
}
