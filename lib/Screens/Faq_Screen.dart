import 'package:flutter/material.dart';

import '../Widgets/SettingsBar.dart';

class faq_screen extends StatefulWidget {
  const faq_screen({Key? key}) : super(key: key);

  @override
  State<faq_screen> createState() => _faq_screenState();
}

class _faq_screenState extends State<faq_screen> {
  bool isshow=false;
  bool isshow2=false;

  @override
  Widget build(BuildContext context) {

    return SettingsBar(
      trailing: false,
      isappbar: true,
      Title: "FAQ",
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            SizedBox(height: 10,),

          InkWell(

            onTap: (){
              setState(() {
                // isshow=true;
                isshow=!isshow;
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                ),
                borderRadius:isshow? BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)):BorderRadius.all(Radius.circular(10)),

                // borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 5, right: 5 , top: 2, bottom: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("📑 What is Lorem Ipsum?" ),
                    Icon(isshow?Icons.arrow_drop_up:Icons.arrow_drop_down)
                  ],
                ),
              ),


            ),
          ),
                 SizedBox(height: 2,),
                 isshow?AnimatedContainer(
                   // Use the properties stored in the State class.
                   width: MediaQuery.of(context).size.width,
                   decoration: BoxDecoration(
                       border: Border.all(
                         color: Colors.black,
                       ),
                     // borderRadius: BorderRadius.all(Radius.circular(10)),

                     borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(10))
                   ),
                   // Define how long the animation should take.
                   duration: const Duration(seconds: 2),
                   // Provide an optional curve to make the animation feel smoother.
                   curve: Curves.fastOutSlowIn,
                   child: Padding(
                     padding: const EdgeInsets.only(left: 5, right: 5 , top: 2, bottom: 2),

                     child: Text("👉 Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."),
                   ),
                 ):SizedBox.shrink(),

            SizedBox(height: 10,),

            InkWell(

            onTap: (){
              setState(() {
                // isshow=true;
                isshow2=!isshow2;
              });
            },

            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                ),
                borderRadius:isshow2? BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)):BorderRadius.all(Radius.circular(10)),

                // borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))
              ),

              child: Padding(
                padding: const EdgeInsets.only(left: 5, right: 5 , top: 2, bottom: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("📑 Why do we use it?" ),
                    Icon(isshow2?Icons.arrow_drop_up:Icons.arrow_drop_down)
                  ],
                ),
              ),


            ),
          ),
                 SizedBox(height: 2,),
            isshow2?AnimatedContainer(
                   // Use the properties stored in the State class.
                   width: MediaQuery.of(context).size.width,
                   decoration: BoxDecoration(
                       border: Border.all(
                         color: Colors.black,
                       ),
                     // borderRadius: BorderRadius.all(Radius.circular(10)),

                     borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(10))
                   ),
                   // Define how long the animation should take.
                   duration: const Duration(seconds: 2),
                   // Provide an optional curve to make the animation feel smoother.
                   curve: Curves.fastOutSlowIn,
                   child: Padding(
                     padding: const EdgeInsets.only(left: 5, right: 5 , top: 2, bottom: 2),

                     child: Text("👉 It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like)"),
                   ),
                 ):SizedBox.shrink()






            // HelpTile(
            //   text: 'Support Requests',
            //   callback: () {
            //     _launchURL();
            //   },
            // ),
          ],
        ),
      ),
    );
    // return Scaffold(
    //
    //   body: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: [
    //       InkWell(
    //
    //         onTap: (){
    //           setState(() {
    //             isshow=true;
    //           });
    //         },
    //         child: Container(
    //           child: Text("question 1"),
    //
    //
    //         ),
    //       ),
    //       isshow?AnimatedContainer(
    //         // Use the properties stored in the State class.
    //         width: 50,
    //         height: 30,
    //         decoration: BoxDecoration(
    //         ),
    //         // Define how long the animation should take.
    //         duration: const Duration(seconds: 1),
    //         // Provide an optional curve to make the animation feel smoother.
    //         curve: Curves.fastOutSlowIn,
    //         child: Text(" answer 1 sdfsdsdf"),
    //       ):SizedBox.shrink()
    //
    //
    //
    //
    //
    //
    //
    //
    //     ],
    //   ),
    //
    // );
  }
}
