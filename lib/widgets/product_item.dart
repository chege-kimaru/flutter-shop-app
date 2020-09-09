import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';

import '../providers/product.dart';
import '../screens/product_details_screen.dart';

class ProductItem extends StatelessWidget {
  // const ProductItem(this.product);

  @override
  Widget build(BuildContext context) {
    // You can either use Provider.of or Consumer to consume your provider data
    // Both are the same
    // the advantage of Consumer is that you can wrap only the widget that changes
    // with this Consumer class hence less rebuilds.
    // You can use them both if you want eg use Provider.of with listen to false
    // then wrap the place that changes with Consumer as we are doing below
    // Note you can use Consumer completely alone as well, it doesn't need Provider.of
    final Product product = Provider.of<Product>(context, listen: false);
    final Cart cart = Provider.of<Cart>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .pushNamed(ProductDetailsScreen.routeName, arguments: product.id);
        },
        child: GridTile(
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
          footer: GridTileBar(
            backgroundColor: Colors.black54,
            // use Consumer as this is the only part that changes
            // just an optimisation
            leading: Consumer<Product>(
              // the child argument is used to define widget in this widget that never changes
              // You define it as an argument to Consumer which will then be passed
              // to the retuned widget
              builder: (ctx, product, child) => IconButton(
                icon: Icon(
                  product.isFavorite != null && product.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Theme.of(context).accentColor,
                ),
                onPressed: () {
                  product.toggleFavoriteStatus();
                },
              ),
              // child will be assed to the child argument in builder
              //child: Text('Label')
            ),
            title: Text(
              product.title,
              textAlign: TextAlign.center,
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.add_shopping_cart,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () {
                cart.addItem(product.id, product.price, product.title);
              },
            ),
          ),
        ),
      ),
    );
  }
}
