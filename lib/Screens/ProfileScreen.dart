import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:owlet/Components/Button.dart';
import 'package:owlet/Components/Loading.dart';
import 'package:owlet/Components/Pipe.dart';
import 'package:owlet/Components/ProfileAvatar.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Providers/GlobalProvider.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Providers/UtilsProvider.dart';
import 'package:owlet/Screens/Followers.dart';
import 'package:owlet/Screens/LoanApplicationScreen.dart';
import 'package:owlet/Screens/NavScreen.dart';
import 'package:owlet/Screens/ProfileEdit.dart';
import 'package:owlet/Screens/Verification.dart';
import 'package:owlet/Widgets/CustomAppBar.dart';
import 'package:owlet/Widgets/ListingGridView.dart';
import 'package:owlet/constants/images.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:owlet/models/User.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

enum MenuOptions { Logout, Verify, Loan }

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  @override
  State<StatefulWidget> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;

    final globalProvider = GlobalProvider(context);
    final utility = Provider.of<UtilsProvider>(context, listen: false);
    const counterTitleStyle = const TextStyle(
      color: Colors.grey,
    );
    var counterStyle = TextStyle(
        fontSize: MediaQuery.of(context).size.height * 0.025,
        color: Colors.black,
        fontWeight: FontWeight.bold);
    var space10 = SizedBox(height: h * 0.01);

    void doLogout() {
      socket.dispose();
      globalProvider.logOut();
    }

    List<String> Story = [
      add,
      fb,
      yt,
      insta,
      tw,
      inn,
    ];

    return Consumer<UserProvider>(builder: (_, user, __) {
      if (!user.isLoggedIn) {
        return Scaffold(
          body: Center(
            child: Loading(
              message: 'Clearing your data',
              showWait: false,
            ),
          ),
        );
      } else {
        var _user = user.profile;
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              CustomAppBar(),
              Expanded(
                child: DefaultTabController(
                  length: 4,
                  child: NestedScrollView(
                    headerSliverBuilder: (context, _) {
                      return [
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              profile(
                                  user,
                                  _user,
                                  context,
                                  utility,
                                  counterStyle,
                                  counterTitleStyle,
                                  space10,
                                  Story),
                            ],
                          ),
                        ),
                      ];
                    },
                    body: Column(
                      children: [
                        space10,
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                          child: TabBar(
                            controller: _tabController,
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Colors.black,
                            indicatorSize: TabBarIndicatorSize.tab,
                            tabs: [
                              Tab(
                                child: SvgPicture.asset(
                                  photos_icon,
                                  height: h * 0.035,
                                ),
                              ),
                              Tab(
                                child: SvgPicture.asset(
                                  video_icon,
                                  height: h * 0.035,
                                ),
                              ),
                              Tab(
                                child: SvgPicture.asset(
                                  reels_icon,
                                  height: h * 0.035,
                                ),
                              ),
                              Tab(
                                child: SvgPicture.asset(
                                  nav_icon,
                                  height: h * 0.035,
                                ),
                              ),
                            ],
                          ),
                        ),
                        space10,
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                ListingGridView(
                                  listings: user.listings,
                                  load: () => user.getListings(),
                                  refresh: () =>
                                      user.getListings(refresh: true),
                                  providerType: ListingProviderType.USER,
                                ),
                                Text("Videos"),
                                Text("Videos"),
                                Text("Videos"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // bottomNavigationBar: BottomNav(),
        );
      }
    });
  }

  Column profile(
      UserProvider user,
      User _user,
      BuildContext context,
      UtilsProvider utility,
      TextStyle counterStyle,
      TextStyle counterTitleStyle,
      SizedBox space,
      List<String> Story) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    var space5 = SizedBox(height: h * 0.000);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: Offset(5, 3),
                  color: Colors.grey.withOpacity(.1),
                  blurRadius: 5.0,
                ),
              ],
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30))),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.050),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                space,
                space,
                MyProfileImage(user: user),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_user.username,
                        style: TextStyle(
                            fontSize: w * 0.055, fontWeight: FontWeight.bold)),
                    space5,
                    Text(
                      _user.fullName,
                      style: TextStyle(color: Colors.grey, fontSize: w * 0.040),
                    ),
                  ],
                ),
                user.profile.bio != null && user.profile.bio!.length > 0
                    ? user.profile.bio!.richText.justify
                        .size(w * 0.040)
                        // .maxLines(5)
                        .make()
                        .box
                        .padding(EdgeInsets.symmetric(vertical: h * 0.010))
                        .make()
                        .w(double.infinity)
                    : SizedBox.shrink(),
                Divider(
                  color: divider.withOpacity(0.5),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              utility.currentSellerProfile = _user;
                              user.getUserFollowers(_user.id, refresh: true);
                              Navigator.pushNamed(
                                context,
                                Followers.routeName,
                                arguments: FollowerScreenArguments(_user),
                              );
                            },
                            child: Column(
                              children: [
                                Text("${_user.totalFollowers}",
                                    style: counterStyle),
                                Text(
                                  'Followers',
                                  style: counterTitleStyle,
                                ),
                              ],
                            ),
                          ),
                          Pipe(height: h * 0.060),
                          GestureDetector(
                            onTap: () {
                              utility.currentSellerProfile = _user;
                              user.getUserFollowing(_user.id, refresh: true);
                              Navigator.pushNamed(
                                context,
                                Followers.routeName,
                                arguments: FollowerScreenArguments(
                                  _user,
                                  type: FollowType.FOLLOWING,
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Text(
                                  "${_user.totalFollowing}",
                                  style: counterStyle,
                                ),
                                Text(
                                  'Following',
                                  style: counterTitleStyle,
                                ),
                              ],
                            ),
                          ),
                          Pipe(height: h * 0.060),
                          Column(
                            children: [
                              Text(
                                '${_user.totalListing}',
                                style: counterStyle,
                              ),
                              Text(
                                'Products',
                                style: counterTitleStyle,
                              ),
                            ],
                          ),
                        ],
                      ),
                      space,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: h * 0.015,
          ),
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, ProfileEdit.routeName);
            },
            child: Container(
              width: screenSize(context).width * 0.9,
              height: screenSize(context).width * 0.12,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.withOpacity(0.35))),
              child: Center(
                child: Text(
                  "Edit Profile",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: w * 0.040,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
        space,
        Padding(
          padding: EdgeInsets.only(left: w * 0.080, top: h * 0.005),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Storefront",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              space,
              space,
              Container(
                height: h * 0.060,
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    itemCount: Story.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: index != 0
                              ? walletcolor.withOpacity(0.3)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(h * 0.001),
                          child: Center(
                            child: Image.asset(Story[index]),
                          ),
                        ),
                      );
                    }),
              ),
              space,
            ],
          ),
        ),
      ],
    );
  }
}

class MyProfileImage extends StatelessWidget {
  MyProfileImage({
    Key? key,
    required UserProvider? user,
  })  : _user = user,
        super(key: key);

  final UserProvider? _user;

  @override
  Widget build(BuildContext context) {
    // void _cropImage(File image) async {
    //   File? cropped = await ImageCropper.cropImage(
    //     sourcePath: image.path,
    //     aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
    //   );

    //   if (cropped != null) {
    //     Navigator.pop(context);
    //     _user!.updateProfileImage(cropped);
    //   }
    // }

    // void _loadPicker(ImageSource source) async {
    //   XFile? picked = await ImagePicker().pickImage(
    //     source: source,
    //     preferredCameraDevice: CameraDevice.front,
    //   );
    //   if (picked != null) _cropImage(File(picked.path));
    // }
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return ProfileAvatar(
      showStatusPainter: false,
      storyNum: _user!.profile.stories.length,
      size: h * 0.12,
      avatar: _user!.profile.avtar,
      // onPressed: () => _showPickOptionDialog(context),
      onPressed: () => Toast(context, message: 'Feature coming soon...').show(),
    );
  }
}

class NestedScrollViewFirstHome extends StatelessWidget {
  const NestedScrollViewFirstHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.0,
              //forceElevated: innerBoxIsScrolled,
              //floating: true,

              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Container(),
                background: Image.network(
                  'https://cdn.pixabay.com/photo/2016/09/10/17/18/book-1659717_960_720.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ];
        },
        body: CustomScrollView(
          slivers: <Widget>[
            SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Container(
                    alignment: Alignment.center,
                    color: Colors.orange[100 * (index % 9)],
                    child: Text('grid item $index'),
                  );
                },
                childCount: 30,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
