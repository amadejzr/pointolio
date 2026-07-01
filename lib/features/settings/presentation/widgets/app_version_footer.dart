import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';

/// App name + version/build footer for Settings, read from the platform
/// package metadata (driven by the pubspec `version:` field).
class AppVersionFooter extends StatelessWidget {
  const AppVersionFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        final name = (info?.appName.isNotEmpty ?? false)
            ? info!.appName
            : 'Pointolio';

        return MergeSemantics(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name, style: PT.bodyStrong(pt.textMuted)),
              if (info != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Version ${info.version} (${info.buildNumber})',
                  style: PT.caption(pt.textFaint),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
