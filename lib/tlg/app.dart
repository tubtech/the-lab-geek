/*
 * The Lab Geek
 * Copyright © 2018 Tub Technology
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'
    show
    debugPaintSizeEnabled,
    debugPaintBaselinesEnabled,
    debugPaintLayerBordersEnabled,
    debugPaintPointersEnabled,
    debugRepaintRainbowEnabled;
import 'package:flutter_localizations/flutter_localizations.dart';

import 'configuration.dart';
import 'data.dart';
import 'strings.dart';

import 'page/experiment.dart';
import 'page/home.dart';
import 'page/settings.dart';
import 'page/debug.dart';

class TlgApp extends StatefulWidget {
  @override
  _State createState() => new _State();
}

class _LocalizationsDelegate extends LocalizationsDelegate<TlgStrings> {
  @override
  Future<TlgStrings> load(Locale locale) => TlgStrings.load(locale);

  @override
  bool isSupported(Locale locale) =>
      (locale.languageCode == 'en' && locale.countryCode == 'GB') ||
          (locale.languageCode == 'en' && locale.countryCode == 'US');

  @override
  bool shouldReload(_LocalizationsDelegate _) => false;
}

class _State extends State<TlgApp> {
  TlgData data;

  TlgConfiguration _configuration = new TlgConfiguration();

  @override
  void initState() {
    super.initState();
    data = new TlgData();
  }

  void configurationUpdate(TlgConfiguration value) {
    setState(() {
      _configuration = value;
    });
  }

  ThemeData get theme {
    switch (_configuration.theme) {
      case TlgTheme.light:
        return new ThemeData(primarySwatch: Colors.blue);
      case TlgTheme.dark:
        return new ThemeData(primarySwatch: Colors.red);
    }
    assert(_configuration.theme != null);
    return null;
  }

  Route<Null> _getRoute(RouteSettings settings) {
    final List<String> path = settings.name.split('/');

    if (path[0] != '') return null;

    if (path[1].startsWith('experiment:')) {
      if (path.length != 2) return null;

      final String id = path[1].split(':')[1];

      return new MaterialPageRoute<Null>(
        settings: settings,
        builder: (BuildContext context) => new TlgPageExperiment(id: id, data: data),
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      debugPaintSizeEnabled = _configuration.debug && _configuration.debugShowSizes;
      debugPaintBaselinesEnabled = _configuration.debug && _configuration.debugShowBaselines;
      debugPaintLayerBordersEnabled = _configuration.debug && _configuration.debugShowLayers;
      debugPaintPointersEnabled = _configuration.debug && _configuration.debugShowPointers;
      debugRepaintRainbowEnabled = _configuration.debug && _configuration.debugShowRainbow;
      return true;
    }());
    return new MaterialApp(
      title: 'The Lab Geek',
      theme: theme,
      debugShowMaterialGrid: _configuration.debug && _configuration.debugShowGrid,
      showPerformanceOverlay: _configuration.debug && _configuration.debugShowPerformanceOverlay,
      showSemanticsDebugger: _configuration.debug && _configuration.debugShowSemanticsDebugger,
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        new _LocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        const Locale('en', 'US'),
        const Locale('en', 'GB'),
      ],
      routes: <String, WidgetBuilder>{
        '/': (BuildContext _) => new TlgPageHome(
          data: data,
          configuration: _configuration,
          configurationUpdate: configurationUpdate,
        ),
        '/settings': (BuildContext _) => new TlgPageSettings(
          configuration: _configuration,
          configurationUpdate: configurationUpdate,
        ),
        '/debug': (BuildContext _) =>
        new TlgPageDebug(
          configuration: _configuration,
          configurationUpdate: configurationUpdate,
        ),
      },
      onGenerateRoute: _getRoute,
    );
  }
}
