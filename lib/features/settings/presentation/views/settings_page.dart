import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiresense/features/settings/domain/models/temperature_unit.dart';
import 'package:tiresense/features/settings/presentation/view_models/settings_view_model.dart';
import 'package:tiresense/l10n/app_localizations.dart';
import 'package:tiresense/shared/layout/page_layout.dart';
import 'package:tiresense/shared/widgets/collapsing_title.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsViewModelProvider);
    final viewModel = ref.watch(settingsViewModelProvider.notifier);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final inset = PageLayout.horizontalInset(constraints.maxWidth);
          
          return CustomScrollView(
            slivers: [
              CollapsingTitleBar(l10n.settings, implyLeading: true),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  inset, PageLayout.listTop, 
                  inset, PageLayout.listBottom
                ),
                sliver: Theme(
                  data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory), 
                  child: SliverList.list(
                    children: [
                      SwitchListTile(
                        title: Text(l10n.continuousSensorStream),
                        subtitle: Text(l10n.continuousSensorStreamSubtitle),
                        value: settings.continuousStream,
                        onChanged: viewModel.setContinuousStream
                      ),
                      SwitchListTile(
                        title: Text(l10n.temperatureUnit),
                        subtitle: Text(l10n.temperatureUnitSubtitle),
                        value: settings.unit == TemperatureUnit.fahrenheit,
                        onChanged: (value) {
                          viewModel.setUnit(value ? TemperatureUnit.fahrenheit : TemperatureUnit.celsius);
                        }
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
