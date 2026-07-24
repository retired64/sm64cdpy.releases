flutter_localization 0.4.1 copy "flutter_localization: ^0.4.1" to clipboard
Published 26 days ago
SDKFlutterPlatformAndroidiOSLinuxmacOSwebWindows
liked status: inactive
468
Readme
Changelog
Example
Installing
Versions
Scores
Flutter Localization 
Flutter Localization is a package used for in-app localization with Map data or JSON assets. It is designed to be easy and fast to implement. This package is inspired by the Flutter SDK flutter_localizations itself. Follow the steps below to use the package, or you can check out a small example project of the package.

Buy Me a Coffee Buy Me a Coffee at ko-fi.com

Breaking Changes 
From version 0.3.0 onward, there is a major update that breaks the code in the initialize flow. Please re-check the Project Configuration section to see more detail of migration from version 0.2 to 0.3. Don't worry, there are only a few things to change and add.
How To Use 
Prepare Language Source 
From version 0.4.0 onward, we support 2 ways of language source (in-memory Map data and JSON asset file).

In-memory Map data: use more RAM but faster load time. Recommend for 3-5 languages support base on amount of content you have in each Map data.
JSON Asset file: use less RAM but slightly slower than in-memory Map data. Recommend for more than 5 languages support with large amount of content.
In-memory Map Data (Map<String, dynamic>) 
Create a dart file which will contain all the Map data of the locale language your app need. You can change the file name, class name, and file path whatever you like. Example:

mixin AppLocale {
  static const String title = 'title';

  static const Map<String, dynamic> EN = {title: 'Localization'};
  static const Map<String, dynamic> KM = {title: 'ការធ្វើមូលដ្ឋានីយកម្ម'};
  static const Map<String, dynamic> JA = {title: 'ローカリゼーション'};
}
Asset File (JSON assets) 
You can also store your translations in JSON files and load them via assets. Asset's path is not restricted but the file name is. You need to name the file follow your supported language code. For example, create assets/i18n/en.json:

{
  "title": "Localization"
}
Then declare the assets in your pubspec.yaml:

flutter:
  assets:
    - assets/i18n/en.json
    - assets/i18n/km.json
    - assets/i18n/ja.json
Project Configuration 
Ensure plugin initialize. Update main function into async function, add WidgetsFlutterBinding.ensureInitialized() and await FlutterLocalization.instance.ensureInitialized() before runApp() function like below.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterLocalization.instance.ensureInitialized();
  runApp(const MyApp());
}
Initialize the FlutterLocalization object (this can be local or global, up to you)

final FlutterLocalization localization = FlutterLocalization.instance;
Provide the list of MapLocale or JsonLocale and startup language for the app. This has to be done only at the main.dart or the MaterialApp in your project.
@override
void initState() {
  super.initState();
  localization.onTranslatedLanguage = _onTranslatedLanguage;
  // Initialize with map-based
  _initializeLocalizationMapBased();
  // or JSON asset base on your language source 
  _initializeLocalizationJsonAsset();
  // make sure to use only 1 type of source
}

// The setState call here is required to rebuild the app after language changes.
void _onTranslatedLanguage(Locale? locale) {
  setState(() {});
}

void _initializeLocalizationMapBased() {
  localization.init(
    initLanguageCode: 'en',
    source: LocalizationSource.map,
    mapLocales: const [
      MapLocale('en', AppLocale.EN),
      MapLocale('km', AppLocale.KM),
      MapLocale('ja', AppLocale.JA),
    ],
  );
}

void _initializeLocalizationJsonAsset() {
  localization.init(
    initLanguageCode: 'en',
    source: LocalizationSource.jsonAsset,
    jsonLocales: const [
      JsonLocale('en', 'assets/i18n/en.json'),
      JsonLocale('km', 'assets/i18n/km.json'),
      JsonLocale('ja', 'assets/i18n/ja.json'),
    ],
  );
}
Add supportedLocales and localizationsDelegates to the MaterialApp
@override
Widget build(BuildContext context) {
  return MaterialApp(
    supportedLocales: localization.supportedLocales,
    localizationsDelegates: localization.localizationsDelegates,
    home: const SettingsScreen(),
  );
}
Call the translate() function anytime you want to translate the app and provide it with the language code
ElevatedButton(
  child: const Text('English'),
  onPressed: () {
    localization.translate('en');
  },
);
To display the value from the Map data, just use the getString() extension by providing the context (the AppLocale.title is the constant from mixin class above)
AppLocale.title.getString(context);
Extras 
You also can get the language name too. If you don't specify the language code for the function, it will return the language name depend on the current app locale
localization.getLanguageName(languageCode: 'en');  // English
localization.getLanguageName(languageCode: 'km');  // ភាសាខ្មែរ
localization.getLanguageName(languageCode: 'ja');  // 日本語

localization.getLanguageName();  // get language name depend on current app locale
If you need to use locale identifier in some case, you can get it from the current locale. The identifier format is languageCode_scriptCode_countryCode. For scriptCode and countryCode are optional, this might return only the languageCode.
localization.currentLocale.localeIdentifier;
Some Update Note 
Version 0.4.0 
Added support for loading translations from JSON assets using the new JsonLocale model.
Introduced LocalizationSource enum to choose between LocalizationSource.map and LocalizationSource.jsonAsset.
Version 0.3.0 
From version 0.3.0 onward, there is a major update that breaks the code in the initialize flow. Please re-check the README document at the beginning of the Project Configuration section to see more. The breaking change is related to:

Update main() function from void to Future<void> async for package ensureInitialized function
Call ensureInitialized() function to init the core functionality of the package
Version 0.1.13 
Added Strings Util and Context Extension for helping with localization text that are dynamic base on language. Check the usage below or the example here.

As for Strings Util, it just formats string normally from the list of arguments to the full text string.
Strings.format('Hello %a, this is me %a.', ['Dara', 'Sopheak']);
// Result: Hello Dara, this is me Sopheak.
As for Context Extension, the full text and arguments you provide, will use to check and get data from the string source. If the result is null, it will return the key that use to get the resource string.
context.formatString('This is %a package, version %a.', [AppLocale.title, 'LATEST'])
// Result: This is Localization package, version LATEST.
Version 0.1.11 
You can provide the font family in the MapLocale model at the init() function that can be from Assets or GoogleFonts package.

// font family from asset
MapLocale('en', AppLocale.EN, fontFamily: 'MuseoSans');

// or from GoogleFonts package
MapLocale('en', AppLocale.EN, fontFamily: GoogleFonts.lato().fontFamily);
Lastly, provide the font family to the MaterialApp's ThemeData

@override
Widget build(BuildContext context) {
    return MaterialApp(
        supportedLocales: localization.supportedLocales,
        localizationsDelegates: localization.localizationsDelegates,
        home: const SettingsScreen(),
        theme: ThemeData(fontFamily: localization.fontFamily),
    );
}

Readme
Changelog
Example
Installing
Versions
Scores
example/lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterLocalization.instance.ensureInitialized();
  runApp(const MyApp());
}

mixin AppLocale {
  static const String title = 'title';
  static const String thisIs = 'thisIs';

  // In-memory map data example
  static const Map<String, dynamic> EN = {
    title: 'Localization',
    thisIs: 'This is %a package, version %a.',
  };
  static const Map<String, dynamic> KM = {
    title: 'ការធ្វើមូលដ្ឋានីយកម្ម',
    thisIs: 'នេះគឺជាកញ្ចប់%a កំណែ%a.',
  };
  static const Map<String, dynamic> JA = {
    title: 'ローカリゼーション',
    thisIs: 'これは%aパッケージ、バージョン%aです。',
  };
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLocalization _localization = FlutterLocalization.instance;

  @override
  void initState() {
    _localization.onTranslatedLanguage = _onTranslatedLanguage;
    _initializeLocalization();
    super.initState();
  }

  Future<void> _initializeLocalization() async {
    _localization.init(
      initLanguageCode: 'en',
      source: LocalizationSource.jsonAsset,
      jsonLocales: const [
        JsonLocale(
          'en',
          'assets/i18n/en.json',
          countryCode: 'US',
          fontFamily: 'Font EN',
        ),
        JsonLocale(
          'km',
          'assets/i18n/km.json',
          countryCode: 'KH',
          fontFamily: 'Font KM',
        ),
        JsonLocale(
          'ja',
          'assets/i18n/ja.json',
          countryCode: 'JP',
          fontFamily: 'Font JA',
        ),
      ],
    );
  }

  void _onTranslatedLanguage(Locale? locale) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: _localization.supportedLocales,
      localizationsDelegates: _localization.localizationsDelegates,
      home: const SettingsScreen(),
      theme: ThemeData(fontFamily: _localization.fontFamily),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FlutterLocalization _localization = FlutterLocalization.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocale.title.getString(context))),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    child: const Text('English'),
                    onPressed: () {
                      _localization.translate('en');
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: ElevatedButton(
                    child: const Text('ភាសាខ្មែរ'),
                    onPressed: () {
                      _localization.translate('km');
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: ElevatedButton(
                    child: const Text('日本語'),
                    onPressed: () {
                      _localization.translate('ja', save: false);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ItemWidget(
              title: 'Current Language',
              content: _localization.getLanguageName(),
            ),
            ItemWidget(
              title: 'Font Family',
              content: _localization.fontFamily,
            ),
            ItemWidget(
              title: 'Locale Identifier',
              content: _localization.currentLocale.localeIdentifier,
            ),
            ItemWidget(
              title: 'String Format',
              content: Strings.format(
                'Hello %a, this is me %a.',
                ['Dara', 'Sopheak'],
              ),
            ),
            ItemWidget(
              title: 'Context Format String',
              content: context.formatString(
                AppLocale.thisIs,
                [AppLocale.title, 'LATEST'],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  const ItemWidget({
    super.key,
    required this.title,
    required this.content,
  });

  final String? title;
  final String? content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(title ?? '')),
          const Text(' : '),
          Expanded(child: Text(content ?? '')),
        ],
      ),
    );
  }
}
