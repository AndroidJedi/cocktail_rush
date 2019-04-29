import 'package:cocktail_rush/lockalization/CrLocalization.dart';
import 'package:cocktail_rush/middleware/store_cocktails_middleware.dart';
import 'package:cocktail_rush/model/app_state.dart';
import 'package:cocktail_rush/presentation/main_page.dart';
import 'package:cocktail_rush/presentation/network/network_connectivity_widget.dart';
import 'package:cocktail_rush/reducers/app_reducers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(CRApp());
}

class CRApp extends StatelessWidget {
  CRApp({Key key}) : super(key: key);

  final store = new Store<AppState>(
    appReducer,
    initialState: AppState.loading(),
    middleware: createStoreCocktailsMiddleware(),
  );

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return new StoreProvider<AppState>(
        store: store,
        child: new MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.pink,
            toggleableActiveColor: Colors.purple,
            unselectedWidgetColor: Colors.purple,
            scaffoldBackgroundColor: Colors.grey[50],
            textTheme: TextTheme(
              headline: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              title: TextStyle(
                  fontSize: 15.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.white),
            ),
          ),
          home: NetworkConnectivityWidget(child: MainPage()),
          localizationsDelegates: [
            CrLocalizationsDelegate(store),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en', ''),
            const Locale('ru', ''),
          ],
        ));
  }
}
