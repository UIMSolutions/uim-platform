/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.application.dto;

import uim.platform.print;
mixin(ShowModule!());

@safe:

struct PrintQueueDTO {
    PrintQueueId queueId;
    TenantId tenantId;
    string name;
    string description;
    string status;
    string printerId;
    string location;
    string costCenter;
    bool isDefault;
    int maxRetries;
    int retentionDays;
    UserId createdBy;
    UserId updatedBy;
}

struct PrintTaskDTO {
    PrintTaskId taskId;
    TenantId tenantId;
    string queueId;
    string documentId;
    string applicationId;
    string senderApplication;
    int copies = 1;
    string paperFormat;
    bool colorPrint;
    bool duplexPrint;
    string tray;
    UserId createdBy;
}

struct PrinterDTO {
    PrinterId printerId;
    TenantId tenantId;
    string name;
    string description;
    string status;
    string protocol;
    string host;
    ushort port = 631;
    string queue;
    string location;
    string model;
    string vendor;
    bool colorCapable;
    bool duplexCapable;
    string clientId;
    UserId createdBy;
    UserId updatedBy;
}

struct PrintDocumentDTO {
    PrintDocumentId documentId;
    TenantId tenantId;
    string fileName;
    string mimeType;
    string format;
    long sizeBytes;
    string storageUri;
    string checksum;
    string description;
    long expiresAt;
    UserId createdBy;
}

struct PrintClientDTO {
    PrintClientId clientId;
    TenantId tenantId;
    string name;
    string description;
    string version_;
    string hostName;
    string ipAddress;
    string osType;
    string osVersion;
    UserId createdBy;
    UserId updatedBy;
}
