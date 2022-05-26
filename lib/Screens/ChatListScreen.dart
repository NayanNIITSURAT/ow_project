import 'package:flutter/material.dart';
import 'package:owlet/Components/Input.dart';
import 'package:owlet/Components/ProfileAvatar.dart';
import 'package:owlet/Components/ReadMore.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Screens/ChatScreen.dart' show ChatScreen;
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:owlet/modals/UsersModal.dart';
import 'package:owlet/models/ChatUser.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

class ChatListScreen extends StatelessWidget {
  static const routeName = 'chats-list';
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context);
    final users = userData.chats;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          VxBox(
            child: SafeArea(
              bottom: false,
              child: VStack([
                HStack(
                  [
                    IconButton(
                      padding: EdgeInsets.only(left: 15),
                      alignment: Alignment.centerLeft,
                      icon: Icon(
                        Icons.arrow_back,
                        color: Vx.black,
                        size: 26,
                      ),
                      onPressed: context.pop,
                    ),
                    'Messages'.text.semiBold.size(20).make(),
                    IconButton(
                      padding: EdgeInsets.all(0),
                      alignment: Alignment.centerRight,
                      icon: Icon(
                        Icons.more_vert_outlined,
                        color: Vx.white,
                        size: 26,
                      ),
                      onPressed: () {},
                    )
                  ],
                  alignment: MainAxisAlignment.spaceBetween,
                  axisSize: MainAxisSize.max,
                ),
                SizedBox(
                    child:
                        Divider(thickness: 1, color: divider.withOpacity(0.5))),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                  child: Input(
                    islable: false,
                    icon: Icons.search,
                    hintText: "Search",
                    padding: EdgeInsets.symmetric(vertical: 3),
                    topPadding: 0,
                    containtpadding: EdgeInsets.fromLTRB(10, 11, 0, 11),
                    width: double.infinity,
                    onSaved: (_) => userData.loadChats(q: _),
                    radius: 10,
                    rightIcon: Icons.search,
                    bgColor: fieldcolor,
                    elevate: false,
                  ),
                ),
              ]),
            ),
          ).bottomRounded(value: 25).color(Vx.white).outerShadowSm.make(),
          VxBox(
            child: users.isNotEmpty
                ? ListView.builder(
                    // shrinkWrap: true,
                    padding: EdgeInsets.all(0),
                    itemCount: users.length,
                    itemBuilder: (_, i) {
                      final user = users[i];

                      return ChatCard(
                        sender: user,
                        press: () {
                          userData.curChatUser = user;
                          Navigator.pushNamed(
                            context,
                            ChatScreen.routeName,
                          );
                        },
                      );
                    })
                : Center(
                    child: 'No active chat yet'.text.make(),
                  ),
          )
              .padding(const EdgeInsets.symmetric(horizontal: 15, vertical: 0))
              .make()
              .expand()
          // .expand(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => UsersModal.show(context),
        child: Icon(
          Icons.person_add_alt_1,
        ),
        backgroundColor: Palette.primaryColor,
      ),
    );
  }
}

class ChatCard extends StatelessWidget {
  const ChatCard({
    Key? key,
    required this.sender,
    required this.press,
  }) : super(key: key);

  bool get lastMsgSeen => sender.unSeenMsgCount == 0;

  final ChatUser sender;
  final Function() press;

  @override
  Widget build(BuildContext context) {
    // print('sender.messages.last.time   ${sender.messages.last.time}');
    return InkWell(
      onTap: press,
      child: ListTile(
        leading: ProfileAvatar(
          avatar: sender.avartar,
          size: 40,
          isOnline: sender.isOnline,
        ),
        title: sender.username.text.semiBold.make(),
        subtitle: ReadMore(
          caption: sender.messages.last.content,
          style: TextStyle(fontSize: 13, color: Colors.black54),
          showReadmore: false,
          maxLength: 30,
        ),
        trailing: VStack(
          [
            timeAgo(sender.messages.last.time ?? DateTime.now().toString())
                .text
                .size(12)
                .color(Palette.primaryColor)
                .textStyle(TextStyle(fontWeight: FontWeight.w600))
                .make(),
            if (!lastMsgSeen)
              VxCircle(
                  child: sender.unSeenMsgCount.text
                      .color(Vx.white)
                      .size(10)
                      .make()
                      .centered(),
                  radius: 22,
                  backgroundColor: Palette.primaryColor,
                  gradient: LinearGradient(colors: [
                    Palette.primaryColor,
                    Colors.yellow.shade900,
                  ]))
          ],
          crossAlignment: CrossAxisAlignment.end,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 0),
        horizontalTitleGap: 10,
      ),
    );
  }
}
