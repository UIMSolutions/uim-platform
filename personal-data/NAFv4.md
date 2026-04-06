# Personal Data Manager Service - NAF v4 Architecture Views

NATO Architecture Framework Version 4 (NAFv4) views for the Personal Data Manager Service.

---

## NCV-1: Capability Taxonomy

### Personal Data Management Capabilities

```
Personal Data Management
  +-- Data Subject Identification
  |     +-- Search by Name
  |     +-- Search by Email
  |     +-- Search by Organization
  |     +-- Classify Subject Type (Private/Corporate/Employee/Contractor/Minor)
  +-- Data Subject Request Processing
  |     +-- Right of Access (Art. 15)
  |     +-- Right to Rectification (Art. 16)
  |     +-- Right to Erasure (Art. 17)
  |     +-- Right to Restriction (Art. 18)
  |     +-- Right to Data Portability (Art. 20)
  |     +-- Right to Object (Art. 21)
  |     +-- Consent Withdrawal (Art. 7(3))
  |     +-- Request Assignment and Tracking
  +-- Personal Data Record Management
  |     +-- Record Creation and Cataloging
  |     +-- Data Category Classification
  |     +-- Sensitivity Classification
  |     +-- Anonymization
  +-- Application Registration
  |     +-- Register Data-Holding Applications
  |     +-- Application Lifecycle (Activate/Suspend)
  |     +-- Endpoint Configuration
  +-- Processing Purpose Management
  |     +-- Define Legal Bases (GDPR Art. 6)
  |     +-- Link Purposes to Applications
  |     +-- Data Protection Officer Assignment
  +-- Consent Lifecycle Management
  |     +-- Consent Recording
  |     +-- Consent Withdrawal
  |     +-- Consent Expiry Tracking
  |     +-- Audit Trail
  +-- Data Retention Management
  |     +-- Retention Rule Definition
  |     +-- Auto-Delete Policies
  |     +-- Expiry Notifications
  +-- Audit and Compliance
        +-- Processing Activity Logging
        +-- Access Logging
        +-- Change Tracking
        +-- Compliance Reporting
```

---

## NCV-2: Capability to Operational Activities Mapping

| Capability | Operational Activity | GDPR Article |
|-----------|---------------------|-------------|
| Data Subject Identification | Identify and classify data subjects in the system | Art. 4(1) |
| Right of Access | Process information requests from data subjects | Art. 15 |
| Right to Rectification | Correct inaccurate personal data upon request | Art. 16 |
| Right to Erasure | Delete or anonymize personal data upon request | Art. 17 |
| Right to Restriction | Restrict processing of personal data | Art. 18 |
| Right to Data Portability | Export personal data in machine-readable format | Art. 20 |
| Right to Object | Process objections to data processing | Art. 21 |
| Consent Management | Record and manage consent lifecycle | Art. 6(1)(a), Art. 7 |
| Processing Purpose Mgmt | Define and maintain lawful bases for processing | Art. 6 |
| Application Registration | Register data-processing applications | Art. 30 |
| Data Retention | Enforce data retention and deletion policies | Art. 5(1)(e) |
| Audit Logging | Maintain records of processing activities | Art. 30 |

---

## NSV-1: Service Taxonomy

### Service Hierarchy

```
Personal Data Manager Platform Service
  +-- Data Subject Service
  |     +-- CRUD Operations
  |     +-- Search (Name, Email, Organization)
  |     +-- Block Subject
  |     +-- Erase (Anonymize) Subject
  +-- Data Subject Request Service
  |     +-- CRUD Operations
  |     +-- Filter by Data Subject
  |     +-- Filter by Status
  |     +-- Process Comments
  +-- Personal Data Record Service
  |     +-- Create/Read/Delete
  |     +-- Filter by Data Subject
  |     +-- Filter by Application
  |     +-- Cross-filter (Subject + Application)
  +-- Registered Application Service
  |     +-- CRUD Operations
  |     +-- Activate Application
  |     +-- Suspend Application
  +-- Processing Purpose Service
  |     +-- CRUD Operations
  |     +-- Filter by Legal Basis
  |     +-- Filter by Application
  +-- Consent Record Service
  |     +-- Create/Read/Delete
  |     +-- Withdraw Consent
  |     +-- Filter by Data Subject
  +-- Retention Rule Service
  |     +-- CRUD Operations
  |     +-- Filter by Application
  |     +-- Filter by Status
  +-- Data Processing Log Service
  |     +-- Create/Read/Delete
  |     +-- Filter by Data Subject
  |     +-- Filter by Request
  +-- Health Service
        +-- Health Check
```

---

## NSV-2: Service Interface Description

### REST API Interface Specification

| Service | Method | Endpoint | Request | Response |
|---------|--------|----------|---------|----------|
| Data Subject | POST | `/api/v1/personal-data/subjects` | CreateDataSubjectRequest | `{id, message}` |
| Data Subject | GET | `/api/v1/personal-data/subjects` | X-Tenant-Id header | `{count, resources[]}` |
| Data Subject | GET | `/api/v1/personal-data/subjects/search` | Query params | `{count, resources[]}` |
| Data Subject | GET | `/api/v1/personal-data/subjects/{id}` | Path param | DataSubject JSON |
| Data Subject | PUT | `/api/v1/personal-data/subjects/{id}` | UpdateDataSubjectRequest | `{id, message}` |
| Data Subject | POST | `/api/v1/personal-data/subjects/{id}/block` | Path param | `{id, message}` |
| Data Subject | POST | `/api/v1/personal-data/subjects/{id}/erase` | Path param | `{id, message}` |
| Data Subject | DELETE | `/api/v1/personal-data/subjects/{id}` | Path param | `{id, message}` |
| Request | POST | `/api/v1/personal-data/requests` | CreateDataSubjectRequestRequest | `{id, message}` |
| Request | GET | `/api/v1/personal-data/requests` | Query filters | `{count, resources[]}` |
| Request | PUT | `/api/v1/personal-data/requests/{id}` | UpdateDataSubjectRequestRequest | `{id, message}` |
| Record | POST | `/api/v1/personal-data/records` | CreatePersonalDataRecordRequest | `{id, message}` |
| Record | GET | `/api/v1/personal-data/records` | Query filters | `{count, resources[]}` |
| Application | POST | `/api/v1/personal-data/applications` | CreateRegisteredApplicationRequest | `{id, message}` |
| Application | POST | `/api/v1/personal-data/applications/{id}/activate` | Path param | `{id, message}` |
| Application | POST | `/api/v1/personal-data/applications/{id}/suspend` | Path param | `{id, message}` |
| Purpose | POST | `/api/v1/personal-data/purposes` | CreateProcessingPurposeRequest | `{id, message}` |
| Purpose | PUT | `/api/v1/personal-data/purposes/{id}` | UpdateProcessingPurposeRequest | `{id, message}` |
| Consent | POST | `/api/v1/personal-data/consents` | CreateConsentRecordRequest | `{id, message}` |
| Consent | POST | `/api/v1/personal-data/consents/{id}/withdraw` | WithdrawConsentRequest | `{id, message}` |
| Retention | POST | `/api/v1/personal-data/retention-rules` | CreateRetentionRuleRequest | `{id, message}` |
| Retention | PUT | `/api/v1/personal-data/retention-rules/{id}` | UpdateRetentionRuleRequest | `{id, message}` |
| Log | POST | `/api/v1/personal-data/logs` | CreateDataProcessingLogRequest | `{id, message}` |
| Health | GET | `/api/v1/health` | - | `{status, service, version}` |

### Multi-Tenancy

All endpoints support multi-tenancy via the `X-Tenant-Id` HTTP header.

---

## NSV-4: Service Orchestration

### Data Subject Access Request (DSAR) Processing Flow

```
1. Data Protection Officer receives DSAR from data subject
2. DPO searches for data subject via Subject Search API
3. DPO creates DataSubjectRequest via Request API
4. System assigns request ID and sets status to "submitted"
5. DPO assigns reviewer, status moves to "inReview"
6. Reviewer queries PersonalDataRecords for the data subject
7. Reviewer queries RegisteredApplications for affected apps
8. Reviewer processes request per type:
   a. Information (Art. 15): Export personal data records
   b. Correction (Art. 16): Update records via application APIs
   c. Erasure (Art. 17): Erase data subject (anonymize)
   d. Restriction (Art. 18): Block data subject
   e. Portability (Art. 20): Export in machine-readable format
   f. Objection (Art. 21): Update processing purposes
   g. Consent Withdrawal: Withdraw consent records
9. Each action is logged via Data Processing Log API
10. Request status updated to "completed" or "rejected"
```

---

## NLV-1: Logical Data Model

### Entity Relationships

```
DataSubject (1) ---< (*) DataSubjectRequest
DataSubject (1) ---< (*) PersonalDataRecord
DataSubject (1) ---< (*) ConsentRecord
DataSubject (1) ---< (*) DataProcessingLog

RegisteredApplication (1) ---< (*) PersonalDataRecord
RegisteredApplication (1) ---< (*) ProcessingPurpose

ProcessingPurpose (1) ---< (*) ConsentRecord
ProcessingPurpose (1) ---< (*) PersonalDataRecord

RetentionRule (1) ---< (*) PersonalDataRecord

DataSubjectRequest (1) ---< (*) DataProcessingLog
```

### Key Enumerations

| Enumeration | Values |
|-------------|--------|
| DataSubjectType | privatePerson, corporateContact, employee, contractor, minor |
| RequestType | information, correction, erasure, restriction, portability, objection, consentWithdrawal |
| RequestStatus | submitted, inReview, processing, completed, rejected, cancelled, expired |
| LegalBasis | consent, contract, legalObligation, vitalInterest, publicTask, legitimateInterest |
| ConsentStatus | active, withdrawn, expired |
| DataSensitivity | public_, internal, confidential, restricted, sensitive |
| DataCategoryType | identification, contact, financial, health, biometric, genetic, political, religious, tradeUnion, sexualOrientation, criminalRecord, childData |

---

## NPV-2: Physical Architecture

### Container Deployment

```
+--------------------------------------------+
|         Kubernetes Cluster                  |
|                                             |
|  +---------------------------------------+  |
|  | Namespace: uim-platform               |  |
|  |                                        |  |
|  |  +----------------------------------+  |  |
|  |  | Deployment: cloud-personal-data  |  |  |
|  |  |                                   |  |  |
|  |  |  +-----------------------------+  |  |  |
|  |  |  | Pod                         |  |  |  |
|  |  |  |                              |  |  |  |
|  |  |  |  Container:                  |  |  |  |
|  |  |  |  uim-personal-data-service   |  |  |  |
|  |  |  |  Port: 8102                  |  |  |  |
|  |  |  |  Non-root user              |  |  |  |
|  |  |  |  Read-only filesystem       |  |  |  |
|  |  |  +-----------------------------+  |  |  |
|  |  +----------------------------------+  |  |
|  |                                        |  |
|  |  ConfigMap: cloud-personal-data-config |  |
|  |    PERSONAL_DATA_HOST: 0.0.0.0        |  |
|  |    PERSONAL_DATA_PORT: 8102           |  |
|  |                                        |  |
|  |  Service: cloud-personal-data         |  |
|  |    Type: ClusterIP                    |  |
|  |    Port: 8102 -> 8102                 |  |
|  +---------------------------------------+  |
+--------------------------------------------+
```

### Resource Limits

| Resource | Request | Limit |
|----------|---------|-------|
| Memory | 64Mi | 256Mi |
| CPU | 100m | 500m |

### Health Probes

| Probe | Path | Interval | Timeout |
|-------|------|----------|---------|
| Liveness | `/api/v1/health` | 30s | 3s |
| Readiness | `/api/v1/health` | 10s | 3s |

---

## NSOV-1: Security Overlay

### Data Protection Measures

| Measure | Implementation |
|---------|---------------|
| Multi-tenancy isolation | X-Tenant-Id header-based data segregation |
| Non-root execution | Container runs as system user `appuser` |
| Read-only filesystem | Container uses `readOnlyRootFilesystem: true` |
| Data anonymization | Erase operation replaces PII with masked values |
| Audit logging | All processing operations logged via DataProcessingLog |
| Input validation | Domain-level validation (DataSubjectValidator) |
| Error handling | Generic error responses prevent information leakage |
| Transport security | TLS termination at ingress/load balancer |

### GDPR Compliance Matrix

| GDPR Principle | Article | Implementation |
|---------------|---------|---------------|
| Lawfulness | Art. 6 | LegalBasis enum, ProcessingPurpose entity |
| Purpose limitation | Art. 5(1)(b) | ProcessingPurpose with specific data categories |
| Data minimization | Art. 5(1)(c) | DataCategoryType classification |
| Accuracy | Art. 5(1)(d) | Correction request type, update operations |
| Storage limitation | Art. 5(1)(e) | RetentionRule with auto-delete |
| Integrity and confidentiality | Art. 5(1)(f) | DataSensitivity classification, access logging |
| Accountability | Art. 5(2) | DataProcessingLog, comprehensive audit trail |
| Consent | Art. 7 | ConsentRecord with full lifecycle |
| Right of access | Art. 15 | Information request type |
| Right to rectification | Art. 16 | Correction request type |
| Right to erasure | Art. 17 | Erasure request type, erase operation |
| Right to restriction | Art. 18 | Restriction request type, block operation |
| Right to portability | Art. 20 | Portability request type, ExportFormat |
| Right to object | Art. 21 | Objection request type |
| Records of processing | Art. 30 | DataProcessingLog entity |
