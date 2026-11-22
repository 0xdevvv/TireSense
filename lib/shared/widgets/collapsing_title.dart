import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tiresense/shared/layout/page_layout.dart';

class CollapsingTitleBar extends StatelessWidget {
  static const _expandedHeight = 96.0;
  static const _expandedScale = 1.01;
  static const _scrolledUnderElevation = 0.5;

  final String title;

  const CollapsingTitleBar(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final surface = Theme.of(context).colorScheme.surface;
    return SliverAppBar(
      pinned: true,
      primary: !landscape,
      expandedHeight: landscape ? 0 : _expandedHeight,
      backgroundColor: surface,
      surfaceTintColor: surface,
      scrolledUnderElevation: _scrolledUnderElevation,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        expandedTitleScale: _expandedScale,
        titlePadding: EdgeInsetsDirectional.only(
          start: PageLayout.margin,
          end: PageLayout.margin,
          bottom: landscape ? 0 : PageLayout.margin,
        ),
        title: _CollapsingTitle(title),
      ),
    );
  }
}

class _CollapsingTitle extends StatelessWidget {
  final String title;

  const _CollapsingTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final landscape = MediaQuery.orientationOf(context) == Orientation.landscape;
    final settings = context .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;
    final theme = Theme.of(context);
    final range = settings.maxExtent - settings.minExtent;
    final collapsed = landscape || range == 0 ? 
      1.0 : ((settings.maxExtent - settings.currentExtent) / range).clamp(0.0, 1.0);

    return SafeArea(
      top: !landscape,
      left: false,
      right: false,
      bottom: false,
      child: SizedBox(
        width: double.infinity,
        child: Align(
          alignment: Alignment.lerp(
            Alignment.bottomLeft,
            Alignment.bottomCenter,
            collapsed,
          )!,
          child: Text(
            title,
            maxLines: 1,
            style: TextStyle(
              fontSize: lerpDouble(28, 17, collapsed),
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.4,
            ),
          ),
        ),
      ),
    );
  }
}
