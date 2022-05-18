import 'package:flutter/material.dart';
import 'package:owlet/Components/CircleButton.dart';
import 'package:owlet/constants/palettes.dart';

class PackageItem extends StatelessWidget {
  const PackageItem({
    this.onPressed,
    required this.contents,
    required this.title,
    required this.price,
    this.color: Palette.primaryColor,
  });
  final Function()? onPressed;
  final List<String> contents;
  final String title;
  final String price;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
          margin: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headline5!
                    .apply(color: Colors.white),
              ),
              SizedBox(height: 10),
              Text(
                price,
                style: Theme.of(context)
                    .textTheme
                    .headline3!
                    .apply(color: Colors.white),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 0.5,
                    color: Colors.white54,
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Column(
                  children: [
                    ...contents.map((e) {
                      var text = Text(
                        e,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .apply(color: Colors.white, fontSizeDelta: 3),
                      );

                      return e == contents[contents.length - 1]
                          ? text
                          : Column(
                              children: [
                                text,
                                Divider(color: Colors.white54),
                              ],
                            );
                    })
                  ],
                ),
              )
            ],
          ),
        ),
        if (onPressed != null)
          Positioned(
            child: CircleButton(
              withBlur: true,
              icon: Icons.chevron_right,
              onPressed: onPressed,
              bgColor: Palette.primaryColor,
              color: Colors.white,
              iconSize: 27,
            ),
            right: 15,
            top: 70,
          ),
      ],
    );
  }
}
