import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

import 'edit_user_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Produts'),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditUserProductScreen.routeName);
              })
        ],
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: ListView.builder(
          itemBuilder: (_, i) {
            return Column(children: [
              UserProductItem(productsData.items[i].id,
                  productsData.items[i].title, productsData.items[i].imageUrl),
              Divider(),
            ]);
          },
          itemCount: productsData.items.length,
        ),
      ),
    );
  }
}