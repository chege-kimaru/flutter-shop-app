import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/helpers/custom_route.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_user_product_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';

import './screens/products_overview_screen.dart';
import './screens/product_details_screen.dart';
import 'providers/products.dart';
import 'providers/cart.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // to use multiple providers use MultiProvider otherwise just use ChangeNotifierProvider
    // as root
    return MultiProvider(
      providers: [
        // use .value if you are using an existing instance eg products[i]
        // use create if you are using a new instance eg Products()
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        // depends on Auth to get the token. Should therefore come after auth
        // in ordernot to lose what is in the products, pass back its contents though
        // existingProducts
        ChangeNotifierProxyProvider<Auth, Products>(
            update: (ctx, auth, existingProducts) => Products(
                auth.token,
                auth.userId,
                existingProducts == null ? [] : existingProducts.items),
            create: null),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
            update: (ctx, auth, existingOrders) => Orders(
                auth.token,
                auth.userId,
                existingOrders == null ? [] : existingOrders.orders),
            create: null),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato',
              visualDensity: VisualDensity.adaptivePlatformDensity,
              // for custom page transition
              pageTransitionsTheme: PageTransitionsTheme(builders: {
                TargetPlatform.android: CustomePageTransitionBuilder(),
                TargetPlatform.iOS: CustomePageTransitionBuilder(),
              })),
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen()),
          routes: {
            ProductDetailsScreen.routeName: (ctx) => ProductDetailsScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditUserProductScreen.routeName: (ctx) => EditUserProductScreen()
          },
        ),
      ),
    );
  }
}
