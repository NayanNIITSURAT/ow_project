

import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:owlet/Components/Button.dart';
import 'package:owlet/Components/Loading.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/Providers/Listing.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Screens/Home.dart';
import 'package:owlet/Screens/NavScreen.dart';
import 'package:owlet/Widgets/CustomAppBar.dart';
import 'package:owlet/Widgets/GalleryThumbnail.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:owlet/services/listing.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class AddListingScreen extends StatefulWidget {
  static const routeName = '/add-listing';
  @override
  _AddListingScreenState createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  // List<File> _assetList = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();

  String caption = '';

  var setFile;
  String? imagePath;

  var result;
  PlatformFile? file;
  List<PlatformFile> fileData = [];
  List<File> _assetList = [];

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await ImagePicker().retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null)
      setState(() {
        _assetList.add(File(response.file!.path));
      });
    else
      Toast(context,
              message: response.exception!.message ?? 'Unable to load image')
          .show();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    final listing = Provider.of<ListingProvider>(context);
    final bool adding = listing.listingStatus == Status.Adding;
    int allowedImagesInt = 3;
    // user.profile.subscription?.package.allowedImages ?? 0;
    void createListing() async {
      try {
        if (caption.length > 0 && _assetList.length > 0) {
          if (!hasHashtag(caption))
            throw 'You need to write caption and must contain at least one hashtag';
          var res = await listing.addListing(NewListing(
            images: _assetList,
            caption: caption,
          ));
          if (res['status']) {
            user.newListing = res['data'];
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => NavScreen()));
          } else
            throw res['message'];
        } else
          throw 'Caption and image required';
      } catch (e) {
        Toast(context, message: e.toString(), duration: Duration(seconds: 7))
            .show();
      }
    }
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            CustomAppBar(),
            Expanded(
              child: listing.listingStatus == Status.Adding
                  ? Center(
                      child: Loading(
                        message: 'Uploading',
                      ),
                    )
                  : SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: [
                            FutureBuilder<void>(
                              future: retrieveLostData(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<void> snapshot) {
                                return GridView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.only(top: 5),
                                  shrinkWrap: true,
                                  itemBuilder: (ctx, i) {
                                    return i == 0
                                        ? InkWell(
                                            onTap: () =>
                                                addImage(allowedImagesInt),
                                            splashColor: Palette.primaryColor,
                                            child: Container(
                                              child: Icon(
                                                i == 0
                                                    ? Icons.add
                                                    : Icons.camera_alt_outlined,
                                                color: Colors.grey[350],
                                                size: 45,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Color(0xffEDF2F7)
                                                    .withOpacity(0.5),
                                                border: Border.all(
                                                  width: 2.5,
                                                  color: Colors.blue
                                                      .withOpacity(0.05),
                                                ),
                                              ),
                                            ),
                                          )
                                        : GalleryThumbnail(
                                            file: _assetList[i - 1],
                                            onDelete: () => setState(() {
                                              _assetList
                                                  .remove(_assetList[i - 1]);
                                            }),
                                          );
                                  },
                                  itemCount: _assetList.length + 1,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 3,
                                          mainAxisSpacing: 3),
                                );
                              },
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: EditListing(
                                onChange: (input) =>
                                    setState(() => caption = input),
                                caption: caption,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Button(
                              width: MediaQuery.of(context).size.width,
                              text: "Add Post",
                              paddingHori: 130,
                              paddingVert: 10,
                              press: () => createListing(),
                            )
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.add),
      //   onPressed:
      // ),
    );
  }

  void _loadPicker({ImageSource source: ImageSource.gallery}) async {
    try {
      XFile? pickedImage = await ImagePicker().pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (pickedImage != null) {
        var imageFile = await ImageCropper().cropImage(
          maxHeight: 700,
          maxWidth: 700,
          compressFormat: ImageCompressFormat.jpg,
          sourcePath: pickedImage.path,
          aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        );

        if (imageFile != null)
          setState(() {
            // _assetList.add(imageFile);
          });
      }
    } catch (e) {
      print(e);
    }
  }

  void _pickFile() async {
    FilePickerResult? pickedImage = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'mp4'],
        allowMultiple: true);
    if (pickedImage == null) return;

    if (pickedImage!.files.length >= 3) {
      scaffoldKey.currentState?.showSnackBar(
          const SnackBar(content: Text('Please Select Only 2 item!')));
    } else {
      if (pickedImage != null) {
        var leng = pickedImage.files.length;
        for (int i = 0; i < leng; i++) {
          PlatformFile pfile = pickedImage.files[i];
          File files = File(pfile.path!);

          // var imageFile = await ImageCropper.cropImage(
          //   maxHeight: 700,
          //   maxWidth: 700,
          //   compressFormat: ImageCompressFormat.jpg,
          //   sourcePath: files.path,
          //   aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
          // );

          if (files != null)
            setState(() {
              _assetList.add(files);
            });
        }
      } else {
        scaffoldKey.currentState?.showSnackBar(
            const SnackBar(content: Text('Please Select Only 3 item!')));
      }
    }
    setState(() {});
  }

  void addImage(allowedImagesInt) => _assetList.length >= allowedImagesInt
      ? Toast(context, message: 'Maximum number of images reached').show()
      : _pickFile();
}

class EditListing extends StatefulWidget {
  const EditListing({
    required this.caption,
    required this.onChange,
  });

  final String caption;
  final Function(String) onChange;

  @override
  _EditListingState createState() => _EditListingState();
}

class _EditListingState extends State<EditListing> {
  final _captionFocusNode = FocusNode();
  late final _captionController;
  // List<HashTag> _searchResult = [];
  @override
  void initState() {
    _captionController = TextEditingController()..text = widget.caption;
    super.initState();
  }

  @override
  void dispose() {
    _captionFocusNode.dispose();
    _captionController.dispose();
    super.dispose();
  }

  void onChange(String caption) {
    widget.onChange(caption);
    handleTagAtInput(caption,
        onTapHashTag: (tag) => setState(() {
              widget.onChange(caption);
              // _searchResult =
              //     Provider.of<HashTagProvider>(context, listen: false)
              // .search(tag);
            }),
        onTapMention: print);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          constraints: BoxConstraints(maxHeight: 300),
          padding: EdgeInsets.only(
            right: 10,
            left: 10,
            bottom: 5,
          ),
          decoration: BoxDecoration(
            color: Color(0xffEDF2F7).withOpacity(0.5),
          ),
          child: TextField(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter caption',
              fillColor: Colors.black,
              // labelText: 'Description',
            ),

            scrollPadding: EdgeInsets.all(10),
            minLines: 5,
            maxLines: 15,
            autofocus: true,
            maxLength: 2200,

            onChanged: (value) => onChange(value),
            // maxLengthEnforcement: ,
            keyboardType: TextInputType.multiline,
            focusNode: _captionFocusNode,
            controller: _captionController,
            textInputAction: TextInputAction.newline,
          ),
        ),
        // ListView.builder(
        //   shrinkWrap: true,
        //   itemCount: _searchResult.length > 4 ? 5 : _searchResult.length,
        //   itemBuilder: (_, i) => InkWell(
        //     onTap: () {},
        //     child: Padding(
        //       padding: const EdgeInsets.symmetric(vertical: 14),
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: [
        //           Text(
        //             "#${_searchResult[i].tag}",
        //             style: TextStyle(
        //               fontWeight: FontWeight.bold,
        //               color: Colors.black54,
        //               fontSize: 12,
        //             ),
        //           ),
        //           Text(
        //             "${_searchResult[i].totalListing} public listings",
        //             style: TextStyle(
        //               fontWeight: FontWeight.bold,
        //               color: Colors.grey,
        //               fontSize: 12,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
