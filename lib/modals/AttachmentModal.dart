import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Widgets/BottomModalLayout.dart';
import 'package:geolocator/geolocator.dart';
import 'package:owlet/Widgets/Chatable.dart';
import 'package:owlet/enum.dart';
import 'package:owlet/modals/UsersModal.dart';

class AttachmentModal extends StatefulWidget {
  static var show = (
    BuildContext ctx, {
    Function(Chatable)? handleChatable,
  }) =>
      showCupertinoModalBottomSheet(
        context: ctx,
        builder: (context) => Container(
          child: AttachmentModal(
            handleChatable: handleChatable,
          ),
        ),
        duration: Duration(milliseconds: 400),
        expand: false,
        barrierColor: Colors.black.withOpacity(0.4),
      );
  const AttachmentModal({
    this.handleChatable,
  });
  final Function(Chatable)? handleChatable;

  @override
  State<AttachmentModal> createState() => _AttachmentModalState();
}

class _AttachmentModalState extends State<AttachmentModal> {
  void _pickLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Toast(context,
              message:
                  'Location services are disabled. Please turn on location on your device')
          .showTop();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Toast(context,
                message:
                    'Location services are required to send your current location.')
            .showTop();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      Toast(context,
              message:
                  'Location permissions are permanently denied on your device, we cannot request permissions.')
          .showTop();
      return;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    (widget.handleChatable ?? (_) {})(
      Chatable(
        type: ChatableType.LOCATION,
        location: await Geolocator.getCurrentPosition(),
      ),
    );
  }

  void _pickFile(
      {required FileType type, List<String>? allowedExtensions}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: allowedExtensions,
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      (widget.handleChatable ??
          (_) {})(Chatable(type: ChatableType.MEDIA, file: file));
    } else {
      // User canceled the picker
    }
  }

  void _pickContact() {
    UsersModal.show(
      context,
      callBack: (user) => (widget.handleChatable ?? (_) {})(Chatable(
        type: ChatableType.USER,
        user: user,
      )),
    );
    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BottomModalLayout(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                iconCreation(
                  Icons.insert_drive_file,
                  Colors.indigo,
                  "Document",
                  onPressed: () => _pickFile(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'doc', 'txt', 'csv', 'xls'],
                  ),
                ),
                SizedBox(
                  width: 40,
                ),
                iconCreation(
                  Icons.camera_alt,
                  Colors.pink,
                  "Camera",
                ),
                SizedBox(
                  width: 40,
                ),
                iconCreation(
                  Icons.insert_photo,
                  Colors.purple,
                  "Gallery",
                  onPressed: () => _pickFile(type: FileType.image),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                iconCreation(
                  Icons.headset,
                  Colors.orange,
                  "Audio",
                  onPressed: () => _pickFile(type: FileType.audio),
                ),
                SizedBox(
                  width: 40,
                ),
                iconCreation(
                  Icons.location_pin,
                  Colors.teal,
                  "Location",
                  onPressed: _pickLocation,
                ),
                SizedBox(
                  width: 40,
                ),
                iconCreation(Icons.person, Colors.blue, "Contact",
                    onPressed: _pickContact),
              ],
            ),
          ],
        ),
      ),
    ]);
  }

  Widget iconCreation(IconData icons, Color color, String text,
      {Function()? onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(
              icons,
              // semanticLabel: "Help",
              size: 29,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              // fontWeight: FontWeight.w100,
            ),
          )
        ],
      ),
    );
  }
}
