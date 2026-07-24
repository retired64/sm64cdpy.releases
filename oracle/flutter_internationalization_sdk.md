UI
i18n
Internationalizing Flutter apps
How to internationalize your Flutter app.

What you'll learn
How to track the device's locale (the user's preferred language).
How to enable locale-specific Material or Cupertino widgets.
How to manage locale-specific app values.
How to define the locales an app supports.
If your app might be deployed to users who speak another language then you'll need to internationalize it. That means you need to write the app in a way that makes it possible to localize values like text and layouts for each language or locale that the app supports. Flutter provides widgets and classes that help with internationalization and the Flutter libraries themselves are internationalized.

This page covers concepts and workflows necessary to localize a Flutter application using the MaterialApp and CupertinoApp classes, as most apps are written that way. However, applications written using the lower level WidgetsApp class can also be internationalized using the same classes and logic.

Introduction to localizations in Flutter
This section provides a tutorial on how to create and internationalize a new Flutter application, along with any additional setup that a target platform might require.

You can find the source code for this example in gen_l10n_example.

Setting up an internation­alized app: the Flutter_localizations package
By default, Flutter only provides US English localizations. To add support for other languages, an application must specify additional MaterialApp (or CupertinoApp) properties, and include a package called flutter_localizations.

To begin, start by creating a new Flutter application in a directory of your choice with the flutter create command.

flutter create <name_of_flutter_app>
To use flutter_localizations, add the package as a dependency to your pubspec.yaml file, as well as the intl package:

flutter pub add flutter_localizations --sdk=flutter
flutter pub add intl:any
This creates a pubspec.yml file with the following entries:

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: any
Then import the flutter_localizations library and specify localizationsDelegates and supportedLocales for your MaterialApp or CupertinoApp:

import 'package:flutter_localizations/flutter_localizations.dart';
return const MaterialApp(
  title: 'Localizations Sample App',
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('en'), // English
    Locale('es'), // Spanish
  ],
  home: MyHomePage(),
);
After introducing the flutter_localizations package and adding the previous code, the Material and Cupertino packages should now be correctly localized in one of the supported locales. Widgets should be adapted to the localized messages, along with correct left-to-right or right-to-left layout.

Try switching the target platform's locale to Spanish (es) and the messages should be localized.

Apps based on WidgetsApp are similar except that the GlobalMaterialLocalizations.delegate isn't needed.

The full Locale.fromSubtags constructor is preferred as it supports scriptCode, though the Locale default constructor is still fully valid.

The elements of the localizationsDelegates list are factories that produce collections of localized values. GlobalMaterialLocalizations.delegate provides localized strings and other values for the Material Components library. GlobalWidgetsLocalizations.delegate defines the default text direction, either left-to-right or right-to-left, for the widgets library.

More information about these app properties, the types they depend on, and how internationalized Flutter apps are typically structured, is covered on this page.


Overriding the locale
Localizations.override is a factory constructor for the Localizations widget that allows for (the typically rare) situation where a section of your application needs to be localized to a different locale than the locale configured for your device.

To observe this behavior, add a call to Localizations.override and a simple CalendarDatePicker:

Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Add the following code
          Localizations.override(
            context: context,
            locale: const Locale('es'),
            // Using a Builder to get the correct BuildContext.
            // Alternatively, you can create a new widget and Localizations.override
            // will pass the updated BuildContext to the new widget.
            child: Builder(
              builder: (context) {
                // A toy example for an internationalized Material widget.
                return CalendarDatePicker(
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                  onDateChanged: (value) {},
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
Hot reload the app and the CalendarDatePicker widget should re-render in Spanish.


Adding your own localized messages
After adding the flutter_localizations package, you can configure localization. To add localized text to your application, complete the following instructions:

Add the intl package as a dependency, pulling in the version pinned by flutter_localizations:

flutter pub add intl:any
Open the pubspec.yaml file and enable the generate flag. This flag is found in the flutter section in the pubspec file.

# The following section is specific to Flutter.
flutter:
  generate: true # Add this line
Add a new yaml file to the root directory of the Flutter project. Name this file l10n.yaml and include the following content:

arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
This file configures the localization tool. In this example, you've done the following:

Put the App Resource Bundle (.arb) input files in ${FLUTTER_PROJECT}/lib/l10n. The .arb provide localization resources for your app.
Set the English template as app_en.arb.
Told Flutter to generate localizations in the app_localizations.dart file.
In ${FLUTTER_PROJECT}/lib/l10n, add the app_en.arb template file. For example:

{
  "helloWorld": "Hello World!",
  "@helloWorld": {
    "description": "The conventional newborn programmer greeting"
  }
}
Add another bundle file called app_es.arb in the same directory. In this file, add the Spanish translation of the same message.

{
    "helloWorld": "¡Hola Mundo!"
}
Now, run flutter pub get or flutter run and codegen takes place automatically. You should find generated files in the directory at the path you specified with the arb-dir or output-dir options Alternatively, you can also run flutter gen-l10n to generate the same files without running the app.

Add the import statement on app_localizations.dart and AppLocalizations.delegate in your call to the constructor for MaterialApp:

import 'l10n/app_localizations.dart';
return const MaterialApp(
  title: 'Localizations Sample App',
  localizationsDelegates: [
    AppLocalizations.delegate, // Add this line
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('en'), // English
    Locale('es'), // Spanish
  ],
  home: MyHomePage(),
);
The AppLocalizations class also provides auto-generated localizationsDelegates and supportedLocales lists. You can use these instead of providing them manually.

const MaterialApp(
  title: 'Localizations Sample App',
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
);
Once the Material app has started, you can use AppLocalizations anywhere in your app:

appBar: AppBar(
  // The [AppBar] title text should update its message
  // according to the system locale of the target platform.
  // Switching between English and Spanish locales should
  // cause this text to update.
  title: Text(AppLocalizations.of(context)!.helloWorld),
),
Note
The Material app has to actually be started to initialize AppLocalizations. If the app hasn't yet started, AppLocalizations.of(context)!.helloWorld causes a null exception.

This code generates a Text widget that displays "Hello World!" if the target device's locale is set to English, and "¡Hola Mundo!" if the target device's locale is set to Spanish. In the arb files, the key of each entry is used as the method name of the getter, while the value of that entry contains the localized message.

The gen_l10n_example uses this tool.

To localize your device app description, pass the localized string to MaterialApp.onGenerateTitle:

return MaterialApp(
  onGenerateTitle: (context) => DemoLocalizations.of(context).title,
Placeholders, plurals, and selects
Tip
When using VS Code, add the arb-editor extension. This extension adds syntax highlighting, snippets, diagnostics, and quick fixes to help edit .arb template files.

You can also include application values in a message with special syntax that uses a placeholder to generate a method instead of a getter. A placeholder, which must be a valid Dart identifier name, becomes a positional parameter in the generated method in the AppLocalizations code. Define a placeholder name by wrapping it in curly braces as follows:

"{placeholderName}"
Define each placeholder in the placeholders object in the app's .arb file. For example, to define a hello message with a userName parameter, add the following to lib/l10n/app_en.arb:

"hello": "Hello {userName}",
"@hello": {
  "description": "A message with a single parameter",
  "placeholders": {
    "userName": {
      "type": "String",
      "example": "Bob"
    }
  }
}
This code snippet adds a hello method call to the AppLocalizations.of(context) object, and the method accepts a parameter of type String; the hello method returns a string. Regenerate the AppLocalizations file.

Replace the code passed into Builder with the following:

// Examples of internationalized strings.
return Column(
  children: <Widget>[
    // Returns 'Hello John'
    Text(AppLocalizations.of(context)!.hello('John')),
  ],
);
You can also use numerical placeholders to specify multiple values. Different languages have different ways to pluralize words. The syntax also supports specifying how a word should be pluralized. A pluralized message must include a num parameter indicating how to pluralize the word in different situations. English, for example, pluralizes "person" to "people", but that doesn't go far enough. The message0 plural might be "no people" or "zero people". The messageFew plural might be "several people", "some people", or "a few people". The messageMany plural might be "most people" or "many people", or "a crowd". Only the more general messageOther field is required. The following example shows what options are available:

"{countPlaceholder, plural, =0{message0} =1{message1} =2{message2} few{messageFew} many{messageMany} other{messageOther}}"
The previous expression is replaced by the message variation (message0, message1, ...) corresponding to the value of the countPlaceholder. Only the messageOther field is required.

The following example defines a message that pluralizes the word, "wombat":

"nWombats": "{count, plural, =0{no wombats} =1{1 wombat} other{{count} wombats}}",
"@nWombats": {
  "description": "A plural message",
  "placeholders": {
    "count": {
      "type": "num",
      "format": "compact"
    }
  }
}
Use a plural method by passing in the count parameter:

// Examples of internationalized strings.
return Column(
  children: <Widget>[
    ...
    // Returns 'no wombats'
    Text(AppLocalizations.of(context)!.nWombats(0)),
    // Returns '1 wombat'
    Text(AppLocalizations.of(context)!.nWombats(1)),
    // Returns '5 wombats'
    Text(AppLocalizations.of(context)!.nWombats(5)),
  ],
);
Similar to plurals, you can also choose a value based on a String placeholder. This is most often used to support gendered languages. The syntax is as follows:

"{selectPlaceholder, select, case{message} ... other{messageOther}}"
The next example defines a message that selects a pronoun based on gender:

"pronoun": "{gender, select, male{he} female{she} other{they}}",
"@pronoun": {
  "description": "A gendered message",
  "placeholders": {
    "gender": {
      "type": "String"
    }
  }
}
Use this feature by passing the gender string as a parameter:

// Examples of internationalized strings.
return Column(
  children: <Widget>[
    ...
    // Returns 'he'
    Text(AppLocalizations.of(context)!.pronoun('male')),
    // Returns 'she'
    Text(AppLocalizations.of(context)!.pronoun('female')),
    // Returns 'they'
    Text(AppLocalizations.of(context)!.pronoun('other')),
  ],
);
Keep in mind that when using select statements, comparison between the parameter and the actual value is case-sensitive. That is, AppLocalizations.of(context)!.pronoun("Male") defaults to the "other" case, and returns "they".

Escaping syntax
Sometimes, you have to use tokens, such as { and }, as normal characters. To ignore such tokens from being parsed, enable the use-escaping flag by adding the following to l10n.yaml:

use-escaping: true
The parser ignores any string of characters wrapped with a pair of single quotes. To use a normal single quote character, use a pair of consecutive single quotes. For example, the following text is converted to a Dart String:

{
  "helloWorld": "Hello! '{Isn''t}' this a wonderful day?"
}
The resulting string is as follows:

"Hello! {Isn't} this a wonderful day?"
Messages with numbers and currencies
Numbers, including those that represent currency values, are displayed very differently in different locales. The localizations generation tool in flutter_localizations uses the NumberFormat class in the intl package to format numbers based on the locale and the desired format.

The int, double, and num types can use any of the following NumberFormat constructors:

Message "format" value	Output for 1200000
compact	"1.2M"
compactCurrency*	"$1.2M"
compactSimpleCurrency*	"$1.2M"
compactLong	"1.2 million"
currency*	"USD1,200,000.00"
decimalPattern	"1,200,000"
decimalPatternDigits*	"1,200,000"
decimalPercentPattern*	"120,000,000%"
percentPattern	"120,000,000%"
scientificPattern	"1E6"
simpleCurrency*	"$1,200,000"
The starred NumberFormat constructors in the table offer optional, named parameters. Those parameters can be specified as the value of the placeholder's optionalParameters object. For example, to specify the optional decimalDigits parameter for compactCurrency, make the following changes to the lib/l10n/app_en.arb file:

"numberOfDataPoints": "Number of data points: {value}",
"@numberOfDataPoints": {
  "description": "A message with a formatted int parameter",
  "placeholders": {
    "value": {
      "type": "int",
      "format": "compactCurrency",
      "optionalParameters": {
        "decimalDigits": 2
      }
    }
  }
}
Messages with dates
Dates strings are formatted in many different ways depending both the locale and the app's needs.

Placeholder values with type DateTime are formatted with DateFormat in the intl package.

There are 41 format variations, identified by the names of their DateFormat factory constructors. In the following example, the DateTime value that appears in the helloWorldOn message is formatted with DateFormat.yMd:

"helloWorldOn": "Hello World on {date}",
"@helloWorldOn": {
  "description": "A message with a date parameter",
  "placeholders": {
    "date": {
      "type": "DateTime",
      "format": "yMd"
    }
  }
}
In an app where the locale is US English, the following expression would produce "7/9/1959". In a Russian locale, it would produce "9.07.1959".

AppLocalizations.of(context).helloWorldOn(DateTime.utc(1959, 7, 9))

Localizing for iOS: Updating the iOS app bundle
Although the localizations are handled by Flutter, you need to add the supported languages in the Xcode project. This ensures your entry in the App Store correctly displays the supported languages.

To configure the locales supported by your app, use the following instructions:

Open your project's ios/Runner.xcodeproj Xcode file.

In the Project Navigator, select the Runner project file under Projects.

Select the Info tab in the project editor.

In the Localizations section, click the Add button (+) to add the supported languages and regions to your project. When asked to choose files and reference language, simply select Finish.

Xcode automatically creates empty .strings files and updates the ios/Runner.xcodeproj/project.pbxproj file. These files are used by the App Store to determine which languages and regions your app supports.


Advanced topics for further customization
This section covers additional ways to customize a localized Flutter application.


Advanced locale definition
Some languages with multiple variants require more than just a language code to properly differentiate.

For example, fully differentiating all variants of Chinese requires specifying the language code, script code, and country code. This is due to the existence of simplified and traditional script, as well as regional differences in the way characters are written within the same script type.

In order to fully express every variant of Chinese for the country codes CN, TW, and HK, the list of supported locales should include:

supportedLocales: [
  Locale.fromSubtags(languageCode: 'zh'), // generic Chinese 'zh'
  Locale.fromSubtags(
    languageCode: 'zh',
    scriptCode: 'Hans',
  ), // generic simplified Chinese 'zh_Hans'
  Locale.fromSubtags(
    languageCode: 'zh',
    scriptCode: 'Hant',
  ), // generic traditional Chinese 'zh_Hant'
  Locale.fromSubtags(
    languageCode: 'zh',
    scriptCode: 'Hans',
    countryCode: 'CN',
  ), // 'zh_Hans_CN'
  Locale.fromSubtags(
    languageCode: 'zh',
    scriptCode: 'Hant',
    countryCode: 'TW',
  ), // 'zh_Hant_TW'
  Locale.fromSubtags(
    languageCode: 'zh',
    scriptCode: 'Hant',
    countryCode: 'HK',
  ), // 'zh_Hant_HK'
],
This explicit full definition ensures that your app can distinguish between and provide the fully nuanced localized content to all combinations of these country codes. If a user's preferred locale isn't specified, Flutter selects the closest match, which likely contains differences to what the user expects. Flutter only resolves to locales defined in supportedLocales and provides scriptCode-differentiated localized content for commonly used languages. See Localizations for information on how the supported locales and the preferred locales are resolved.

Although Chinese is a primary example, other languages like French (fr_FR, fr_CA) should also be fully differentiated for more nuanced localization.


Tracking the locale: The Locale class and the Localizations widget
The Locale class identifies the user's language. Mobile devices support setting the locale for all applications, usually using a system settings menu. Internationalized apps respond by displaying values that are locale-specific. For example, if the user switches the device's locale from English to French, then a Text widget that originally displayed "Hello World" would be rebuilt with "Bonjour le monde".

The Localizations widget defines the locale for its child and the localized resources that the child depends on. The WidgetsApp widget creates a Localizations widget and rebuilds it if the system's locale changes.

You can always look up an app's current locale with Localizations.localeOf():

Locale myLocale = Localizations.localeOf(context);

Specifying the app's supported­Locales parameter
Although the flutter_localizations library supports many languages and language variants, only English language translations are available by default. It's up to the developer to decide exactly which languages to support.

The MaterialApp supportedLocales parameter limits locale changes. When the user changes the locale setting on their device, the app's Localizations widget only follows suit if the new locale is a member of this list. If an exact match for the device locale isn't found, then the first supported locale with a matching languageCode is used. If that fails, then the first element of the supportedLocales list is used.

An app that wants to use a different "locale resolution" method can provide a localeResolutionCallback. For example, to have your app unconditionally accept whatever locale the user selects:

MaterialApp(
  localeResolutionCallback: (locale, supportedLocales) {
    return locale;
  },
);
Configuring the l10n.yaml file
The l10n.yaml file allows you to configure the gen-l10n tool to specify the following:

where all the input files are located
where all the output files should be created
what Dart class name to give your localizations delegate
For a full list of options, either run flutter gen-l10n --help at the command line or refer to the following table:

Option	Description
arb-dir	The directory where the template and translated arb files are located. The default is lib/l10n .
output-dir	The directory where the generated localization classes are written. This option is only relevant if you want to generate the localizations code somewhere else in the Flutter project. You also need to set the synthetic-package flag to false.

The app must import the file specified in the output-localization-file option from this directory. If unspecified, this defaults to the same directory as the input directory specified in arb-dir .
template-arb-file	The template arb file that is used as the basis for generating the Dart localization and messages files. The default is app_en.arb .
output-localization-file	The filename for the output localization and localizations delegate classes. The default is app_localizations.dart .
untranslated-messages-file	The location of a file that describes the localization messages haven't been translated yet. Using this option creates a JSON file at the target location, in the following format:

"locale": ["message_1", "message_2" ... "message_n"]

If this option is not specified, a summary of the messages that haven't been translated are printed on the command line.
output-class	The Dart class name to use for the output localization and localizations delegate classes. The default is AppLocalizations .
preferred-supported-locales	The list of preferred supported locales for the application. By default, the tool generates the supported locales list in alphabetical order. Use this flag to default to a different locale.

For example, pass in [ en_US ] to default to American English if a device supports it.
header	The header to prepend to the generated Dart localizations files. This option takes in a string.

For example, pass in "/// All localized files." to prepend this string to the generated Dart file.

Alternatively, check out the header-file option to pass in a text file for longer headers.
header-file	The header to prepend to the generated Dart localizations files. The value of this option is the name of the file that contains the header text that is inserted at the top of each generated Dart file.

Alternatively, check out the header option to pass in a string for a simpler header.

This file should be placed in the directory specified in arb-dir .
[no-]use-deferred-loading	Specifies whether to generate the Dart localization file with locales imported as deferred, allowing for lazy loading of each locale in Flutter web.

This can reduce a web app's initial startup time by decreasing the size of the JavaScript bundle. When this flag is set to true, the messages for a particular locale are only downloaded and loaded by the Flutter app as they are needed. For projects with a lot of different locales and many localization strings, it can improve performance to defer loading. For projects with a small number of locales, the difference is negligible, and might slow down the start up compared to bundling the localizations with the rest of the application.

Note that this flag doesn't affect other platforms such as mobile or desktop.
gen-inputs-and-outputs-list	When specified, the tool generates a JSON file containing the tool's inputs and outputs, named gen_l10n_inputs_and_outputs.json .

This can be useful for keeping track of which files of the Flutter project were used when generating the latest set of localizations. For example, the Flutter tool's build system uses this file to keep track of when to call gen_l10n during hot reload.

The value of this option is the directory where the JSON file is generated. When null, the JSON file won't be generated.
synthetic-package	Determines whether the generated output files are generated as a synthetic package or at a specified directory in the Flutter project. This flag is true by default. When synthetic-package is set to false , it generates the localizations files in the directory specified by arb-dir by default. If output-dir is specified, files are generated there.
project-dir	When specified, the tool uses the path passed into this option as the directory of the root Flutter project.

When null, the relative path to the present working directory is used.
[no-]required-resource-attributes	Requires all resource ids to contain a corresponding resource attribute.

By default, simple messages won't require metadata, but it's highly recommended as this provides context for the meaning of a message to readers.

Resource attributes are still required for plural messages.
[no-]nullable-getter	Specifies whether the localizations class getter is nullable.

By default, this value is true so that Localizations.of(context) returns a nullable value for backwards compatibility. If this value is false, then a null check is performed on the returned value of Localizations.of(context) , removing the need for null checking in user code.
[no-]format	When specified, the dart format command is run after generating the localization files.
use-escaping	Specifies whether to enable the use of single quotes as escaping syntax.
[no-]suppress-warnings	When specified, all warnings are suppressed.
[no-]relax-syntax	When specified, the syntax is relaxed so that the special character "{" is treated as a string if not followed by a valid placeholder and "}" is treated as a string if it doesn't close any previous "{" that is treated as a special character.
[no-]use-named-parameters	Whether to use named parameters for the generated localization methods.
How internationalization in Flutter works
This section covers the technical details of how localizations work in Flutter. If you're planning on supporting your own set of localized messages, the following content would be helpful. Otherwise, you can skip this section.


Loading and retrieving localized values
The Localizations widget is used to load and look up objects that contain collections of localized values. Apps refer to these objects with Localizations.of(context,type). If the device's locale changes, the Localizations widget automatically loads values for the new locale and then rebuilds widgets that used it. This happens because Localizations works like an InheritedWidget. When a build function refers to an inherited widget, an implicit dependency on the inherited widget is created. When an inherited widget changes (when the Localizations widget's locale changes), its dependent contexts are rebuilt.

Localized values are loaded by the Localizations widget's list of LocalizationsDelegates. Each delegate must define an asynchronous load() method that produces an object that encapsulates a collection of localized values. Typically these objects define one method per localized value.

In a large app, different modules or packages might be bundled with their own localizations. That's why the Localizations widget manages a table of objects, one per LocalizationsDelegate. To retrieve the object produced by one of the LocalizationsDelegate's load methods, specify a BuildContext and the object's type.

For example, the localized strings for the Material Components widgets are defined by the MaterialLocalizations class. Instances of this class are created by a LocalizationDelegate provided by the MaterialApp class. They can be retrieved with Localizations.of():

Localizations.of<MaterialLocalizations>(context, MaterialLocalizations);
This particular Localizations.of() expression is used frequently, so the MaterialLocalizations class provides a convenient shorthand:

static MaterialLocalizations of(BuildContext context) {
  return Localizations.of<MaterialLocalizations>(context, MaterialLocalizations);
}

/// References to the localized values defined by MaterialLocalizations
/// are typically written like this:

tooltip: MaterialLocalizations.of(context).backButtonTooltip,

Defining a class for the app's localized resources
Putting together an internationalized Flutter app usually starts with the class that encapsulates the app's localized values. The example that follows is typical of such classes.

Complete source code for the intl_example for this app.

This example is based on the APIs and tools provided by the intl package. The An alternative class for the app's localized resources section describes an example that doesn't depend on the intl package.

The DemoLocalizations class (defined in the following code snippet) contains the app's strings (just one for the example) translated into the locales that the app supports. It uses the initializeMessages() function generated by Dart's intl package, Intl.message(), to look them up.

class DemoLocalizations {
  DemoLocalizations(this.localeName);

  static Future<DemoLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode == null || locale.countryCode!.isEmpty
        ? locale.languageCode
        : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((_) {
      return DemoLocalizations(localeName);
    });
  }

  static DemoLocalizations of(BuildContext context) {
    return Localizations.of<DemoLocalizations>(context, DemoLocalizations)!;
  }

  final String localeName;

  String get title {
    return Intl.message(
      'Hello World',
      name: 'title',
      desc: 'Title for the Demo application',
      locale: localeName,
    );
  }
}
A class based on the intl package imports a generated message catalog that provides the initializeMessages() function and the per-locale backing store for Intl.message(). The message catalog is produced by an intl tool that analyzes the source code for classes that contain Intl.message() calls. In this case that would just be the DemoLocalizations class.


Adding support for a new language
An app that needs to support a language that's not included in GlobalMaterialLocalizations has to do some extra work: it must provide about 70 translations ("localizations") for words or phrases and the date patterns and symbols for the locale.

See the following for an example of how to add support for the Norwegian Nynorsk language.

A new GlobalMaterialLocalizations subclass defines the localizations that the Material library depends on. A new LocalizationsDelegate subclass, which serves as factory for the GlobalMaterialLocalizations subclass, must also be defined.

Here's the source code for the complete add_language example, minus the actual Nynorsk translations.

The locale-specific GlobalMaterialLocalizations subclass is called NnMaterialLocalizations, and the LocalizationsDelegate subclass is _NnMaterialLocalizationsDelegate. The value of NnMaterialLocalizations.delegate is an instance of the delegate, and is all that's needed by an app that uses these localizations.

The delegate class includes basic date and number format localizations. All of the other localizations are defined by String valued property getters in NnMaterialLocalizations, like this:

@override
String get moreButtonTooltip => r'More';

@override
String get aboutListTileTitleRaw => r'About $applicationName';

@override
String get alertDialogLabel => r'Alert';
These are the English translations, of course. To complete the job you need to change the return value of each getter to an appropriate Nynorsk string.

The getters return "raw" Dart strings that have an r prefix, such as r'About $applicationName', because sometimes the strings contain variables with a $ prefix. The variables are expanded by parameterized localization methods:

@override
String get pageRowsInfoTitleRaw => r'$firstRow–$lastRow of $rowCount';

@override
String get pageRowsInfoTitleApproximateRaw =>
    r'$firstRow–$lastRow of about $rowCount';
The date patterns and symbols of the locale also need to be specified, which are defined in the source code as follows:

const nnLocaleDatePatterns = {
  'd': 'd.',
  'E': 'ccc',
  'EEEE': 'cccc',
  'LLL': 'LLL',
  // ...
}
const Map<String, Object?> nnDateSymbols = {
  'NAME': 'nn',
  'ERAS': <dynamic>['f.Kr.', 'e.Kr.'],
These values need to be modified for the locale to use the correct date formatting. Unfortunately, since the intl library doesn't share the same flexibility for number formatting, the formatting for an existing locale must be used as a substitute in _NnMaterialLocalizationsDelegate:

class _NnMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _NnMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'nn';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    final String localeName = intl.Intl.canonicalizedLocale(locale.toString());

    // The locale (in this case `nn`) needs to be initialized into the custom
    // date symbols and patterns setup that Flutter uses.
    date_symbol_data_custom.initializeDateFormattingCustom(
      locale: localeName,
      patterns: nnLocaleDatePatterns,
      symbols: intl.DateSymbols.deserializeFromMap(nnDateSymbols),
    );

    return SynchronousFuture<MaterialLocalizations>(
      NnMaterialLocalizations(
        localeName: localeName,
        // The `intl` library's NumberFormat class is generated from CLDR data
        // (see https://github.com/dart-lang/i18n/blob/main/pkgs/intl/lib/number_symbols_data.dart).
        // Unfortunately, there is no way to use a locale that isn't defined in
        // this map and the only way to work around this is to use a listed
        // locale's NumberFormat symbols. So, here we use the number formats
        // for 'en_US' instead.
        decimalFormat: intl.NumberFormat('#,##0.###', 'en_US'),
        twoDigitZeroPaddedFormat: intl.NumberFormat('00', 'en_US'),
        // DateFormat here will use the symbols and patterns provided in the
        // `date_symbol_data_custom.initializeDateFormattingCustom` call above.
        // However, an alternative is to simply use a supported locale's
        // DateFormat symbols, similar to NumberFormat above.
        fullYearFormat: intl.DateFormat('y', localeName),
        compactDateFormat: intl.DateFormat('yMd', localeName),
        shortDateFormat: intl.DateFormat('yMMMd', localeName),
        mediumDateFormat: intl.DateFormat('EEE, MMM d', localeName),
        longDateFormat: intl.DateFormat('EEEE, MMMM d, y', localeName),
        yearMonthFormat: intl.DateFormat('MMMM y', localeName),
        shortMonthDayFormat: intl.DateFormat('MMM d'),
      ),
    );
  }

  @override
  bool shouldReload(_NnMaterialLocalizationsDelegate old) => false;
}
For more information about localization strings, check out the flutter_localizations README.

Once you've implemented your language-specific subclasses of GlobalMaterialLocalizations and LocalizationsDelegate, you need to add the language and a delegate instance to your app. The following code sets the app's language to Nynorsk and adds the NnMaterialLocalizations delegate instance to the app's localizationsDelegates list:

const MaterialApp(
  localizationsDelegates: [
    GlobalWidgetsLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    NnMaterialLocalizations.delegate, // Add the newly created delegate
  ],
  supportedLocales: [Locale('en', 'US'), Locale('nn')],
  home: Home(),
),

Alternative internationalization workflows
This section describes different approaches to internationalize your Flutter application.


An alternative class for the app's localized resources
The previous example was defined in terms of the Dart intl package. You can choose your own approach for managing localized values for the sake of simplicity or perhaps to integrate with a different i18n framework.

Complete source code for the minimal app.

In the following example, the DemoLocalizations class includes all of its translations directly in per language Maps:

class DemoLocalizations {
  DemoLocalizations(this.locale);

  final Locale locale;

  static DemoLocalizations of(BuildContext context) {
    return Localizations.of<DemoLocalizations>(context, DemoLocalizations)!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {'title': 'Hello World'},
    'es': {'title': 'Hola Mundo'},
  };

  static List<String> languages() => _localizedValues.keys.toList();

  String get title {
    return _localizedValues[locale.languageCode]!['title']!;
  }
}
In the minimal app the DemoLocalizationsDelegate is slightly different. Its load method returns a SynchronousFuture because no asynchronous loading needs to take place.

class DemoLocalizationsDelegate
    extends LocalizationsDelegate<DemoLocalizations> {
  const DemoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      DemoLocalizations.languages().contains(locale.languageCode);

  @override
  Future<DemoLocalizations> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    return SynchronousFuture<DemoLocalizations>(DemoLocalizations(locale));
  }

  @override
  bool shouldReload(DemoLocalizationsDelegate old) => false;
}

Using the Dart intl tools
Before building an API using the Dart intl package, review the intl package's documentation. The following list summarizes the process for localizing an app that depends on the intl package:

The demo app depends on a generated source file called l10n/messages_all.dart, which defines all of the localizable strings used by the app.

Rebuilding l10n/messages_all.dart requires two steps.

With the app's root directory as the current directory, generate l10n/intl_messages.arb from lib/main.dart:

dart run intl_translation:extract_to_arb --output-dir=lib/l10n lib/main.dart
The intl_messages.arb file is a JSON format map with one entry for each Intl.message() function defined in main.dart. This file serves as a template for the English and Spanish translations, intl_en.arb and intl_es.arb. These translations are created by you, the developer.

With the app's root directory as the current directory, generate intl_messages_<locale>.dart for each intl_<locale>.arb file and intl_messages_all.dart, which imports all the message files:

dart run intl_translation:generate_from_arb \
    --output-dir=lib/l10n --no-use-deferred-loading \
    lib/main.dart lib/l10n/intl_*.arb
Windows doesn't support file name wildcarding. Instead, list the .arb files that were generated by the intl_translation:extract_to_arb command.

dart run intl_translation:generate_from_arb \
    --output-dir=lib/l10n --no-use-deferred-loading \
    lib/main.dart \
    lib/l10n/intl_en.arb lib/l10n/intl_fr.arb lib/l10n/intl_messages.arb
The DemoLocalizations class uses the generated initializeMessages() function (defined in intl_messages_all.dart) to load the localized messages and Intl.message() to look them up.

More information
If you learn best by reading code, check out the following examples.

minimal
The minimal example is designed to be as simple as possible.
intl_example
uses APIs and tools provided by the intl package.
If Dart's intl package is new to you, check out Using the Dart intl tools.

Was this page's content helpful?
