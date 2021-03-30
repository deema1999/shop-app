import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String productId;
  final String title;
  final String imageUrl;

  UserProductItem(
    this.productId,
    this.title,
    this.imageUrl,
  );

  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold.of(context);

    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 8,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        ),
        title: Text(title),
        trailing: Container(
          width: 100,
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.delete,
                  size: 24,
                  color: Theme.of(context).errorColor,
                ),
                onPressed: () async {
                  try {
                    await Provider.of<Products>(
                      context,
                      listen: false,
                    ).deleteProduct(productId);
                  } catch (error) {
                    scaffold.showSnackBar(
                      SnackBar(
                        content: Text(
                          "Delete Failed !",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.edit,
                  size: 24,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    EditProductScreen.routeName,
                    arguments: productId,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
