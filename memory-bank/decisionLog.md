# Decision Log

This file records architectural and implementation decisions...

[2026-01-09 16:10:15] - Fixed output path issue for job applications: Changed generate_application_usecase.dart to use jobReq.concern?.name ?? 'unknown' instead of jobReq.whereFound for the concern directory.

-
