import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders.dart' show Orders;
import 'package:shop_app/widgets/app_drawer.dart';
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  var _isLoading = false;

  Future _ordersFuture;

  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    // You can as well Use a Future Builder as we have done in this case
    // setState(() => _isLoading = true);
    // Future.delayed(Duration.zero).then((_) async {
    //   // when you use lsiten: false you don't have to use the Future.delayed as i've
    //   // done in this case. This is because we won't need the context per say
    //   await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
    //   setState(() => _isLoading = false);
    // });

    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // since you are using a futureBuilder, using this here will cause an infinite loop
    // instead use a consumer on the specific widget
    // final ordersData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Orders',
        ),
      ),
      drawer: AppDrawer(),
      // with this, you can now convert the widget into a stateless widget again
      body: FutureBuilder(
          // setting future like this may cause it be called multiple times
          // if the build method is called, thus we use the second approach
          // future:
          //     Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
          future: _ordersFuture,
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (dataSnapshot.error != null) {
                return Center(child: Text('An error occurred'));
              } else {
                return Consumer<Orders>(
                  builder: (
                    ctx,
                    ordersData,
                    child,
                  ) =>
                      ListView.builder(
                    itemBuilder: (ctx, i) => OrderItem(ordersData.orders[i]),
                    itemCount: ordersData.orders.length,
                  ),
                );
              }
            }
          }),
      // body: _isLoading
      //     ? Center(child: CircularProgressIndicator())
      // : ListView.builder(
      //     itemBuilder: (ctx, i) => OrderItem(ordersData.orders[i]),
      //     itemCount: ordersData.orders.length,
      //   ),
    );
  }
}
