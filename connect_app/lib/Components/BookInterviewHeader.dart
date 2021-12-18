import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  String imageUrl;
  bool toCover;
  PageHeader(this.imageUrl, this.toCover);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      margin: EdgeInsets.only(bottom: 10),
      width: MediaQuery.of(context).size.width - 20,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(imageUrl),
              fit: toCover? BoxFit.cover : BoxFit.contain
          )
      ),
    );
  }
}
