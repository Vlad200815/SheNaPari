import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';

abstract class BaseOtaUpdatePage extends StatelessWidget {
  const BaseOtaUpdatePage({super.key});

  Stream<OtaEvent> get updateStream;

  Widget buildView(BuildContext context, OtaEvent? status);

  @override
  Widget build(BuildContext context) {
    bool hasPopped = false;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: StreamBuilder<OtaEvent>(
          stream: updateStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              debugPrint(
                'OTA Update Status: ${snapshot.data!.status}, Progress: ${snapshot.data!.value}',
              );
            } else if (snapshot.hasError) {
              debugPrint('OTA Update Error: ${snapshot.error}');
            } else if (snapshot.connectionState == ConnectionState.done) {
              debugPrint('OTA Stream completed');
            }

            if (!hasPopped &&
                (snapshot.hasError ||
                    snapshot.connectionState == ConnectionState.done)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!hasPopped && context.mounted) {
                  hasPopped = true;
                  debugPrint(
                    'Closing OTA page due to stream completion or error',
                  );
                  Navigator.of(context).pop();
                }
              });
            } else if (snapshot.hasData && !hasPopped) {
              final status = snapshot.data!.status;
              if ([
                OtaStatus.DOWNLOAD_ERROR,
                OtaStatus.CHECKSUM_ERROR,
                OtaStatus.INTERNAL_ERROR,
                OtaStatus.PERMISSION_NOT_GRANTED_ERROR,
                OtaStatus.ALREADY_RUNNING_ERROR,
                OtaStatus.CANCELED,
              ].contains(status)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!hasPopped && context.mounted) {
                    hasPopped = true;
                    debugPrint('Closing OTA page due to error status: $status');
                  }
                });
              }
            }

            return buildView(context, snapshot.data);
          },
        ),
      ),
    );
  }
}
