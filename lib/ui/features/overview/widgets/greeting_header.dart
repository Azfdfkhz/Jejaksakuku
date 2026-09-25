import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jejak_saku/ui/core/theme/app_typography.dart';
import 'package:jejak_saku/ui/core/theme/app_spacing.dart';
import 'package:jejak_saku/ui/features/overview/view_models/overview_view_model.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OverviewViewModel>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${vm.greeting}, ${vm.greetingName}! ${vm.greetingEmoji}',
          style: AppTypography.pageTitle,
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          'Hari ini kamu punya beberapa kegiatan penting. Yuk, atur waktumu dengan baik!',
          style: AppTypography.body,
        ),
      ],
    );
  }
}
