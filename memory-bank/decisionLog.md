# Decision Log

This file records architectural and implementation decisions...

[2026-01-09 16:10:15] - Fixed output path issue for job applications: Changed generate_application_usecase.dart to use jobReq.concern?.name ?? 'unknown' instead of jobReq.whereFound for the concern directory.

-

[2026-01-10 12:48:32] - Removed FileJobReqDataSource and its implementation as it was complex and brittle. Replaced with AI-based parsing in JobReqRepositoryImpl.getJobReq using the same logic from CreateJobReqUsecase. Updated repository constructor to inject AiService instead of FileJobReqDatasource. Updated tests accordingly and removed unused imports.
