import 'dart:io';

import 'package:flutter/material.dart';
import 'package:owlet/Components/Button.dart';
import 'package:owlet/Components/Loading.dart';
import 'package:owlet/Screens/CameraScreen.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:photo_manager/photo_manager.dart';

class AddMarketSquareScreen extends StatefulWidget {
  static const routeName = 'addMarketSquare';
  @override
  State<StatefulWidget> createState() {
    return _AddMarketSquareScreenState();
  }
}

class _AddMarketSquareScreenState extends State<AddMarketSquareScreen> {
  List<Map<String, dynamic>> selectedMedia = [];

  /// Customize your own filter options.
  final FilterOptionGroup _filterOptionGroup = FilterOptionGroup(
    imageOption: const FilterOption(
      sizeConstraint: SizeConstraint(ignoreSize: true),
    ),
  );
  final int _sizePerPage = 50;

  AssetPathEntity? _path;
  List<AssetEntity>? _entities;
  int _totalEntitiesCount = 0;

  int _page = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreToLoad = true;

  Future<void> _requestAssets() async {
    setState(() {
      _isLoading = true;
    });
    // Request permissions.
    final PermissionState _ps = await PhotoManager.requestPermissionExtend();
    if (!mounted) {
      return;
    }
    // Further requests can be only procceed with authorized or limited.
    if (_ps != PermissionState.authorized && _ps != PermissionState.limited) {
      setState(() {
        _isLoading = false;
      });

      return;
    }
    // Obtain assets using the path entity.
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      onlyAll: true,
      filterOption: _filterOptionGroup,
    );
    if (!mounted) {
      return;
    }
    // Return if not paths found.
    if (paths.isEmpty) {
      setState(() {
        _isLoading = false;
      });

      return;
    }
    setState(() {
      _path = paths.first;
    });
    _totalEntitiesCount = _path!.assetCount;
    final List<AssetEntity> entities = await _path!.getAssetListPaged(
      page: 0,
      size: _sizePerPage,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _entities = entities;
      _isLoading = false;
      _hasMoreToLoad = _entities!.length < _totalEntitiesCount;
    });
  }

  Future<void> _loadMoreAsset() async {
    final List<AssetEntity> entities = await _path!.getAssetListPaged(
      page: _page + 1,
      size: _sizePerPage,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _entities!.addAll(entities);
      _page++;
      _hasMoreToLoad = _entities!.length < _totalEntitiesCount;
      _isLoadingMore = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _requestAssets();
  }

  Widget _buildImageGrid(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: Loading(
        showWait: true,
        message: "Fetching your media",
      ));
    }
    if (_path == null) {
      return const Center(child: Text('Request paths first.'));
    }
    if (_entities?.isNotEmpty != true) {
      return const Center(child: Text('No assets found on this device.'));
    }
    return GridView.custom(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, childAspectRatio: 0.5),
      childrenDelegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (index == _entities!.length - 8 &&
              !_isLoadingMore &&
              _hasMoreToLoad) {
            _loadMoreAsset();
          }

          if ((index == 0)) {
            return InkWell(
              onTap: () => Navigator.pushNamed(context, CameraScreen.routeName),
              child: Container(
                color: Colors.blue.shade50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.black,
                    ),
                    Text("Camera")
                  ],
                ),
              ),
            );
          } else {
            final AssetEntity entity;

            entity = _entities![index - 1];
            int id = -1;
            if (selectedMedia.isNotEmpty) {
              id = selectedMedia
                  .indexWhere((element) => element['id'] == entity.id);
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                InkWell(
                  onTap: () async {
                    if (id != -1) {
                      selectedMedia.removeAt(id);
                    } else {
                      final file = await entity.file;
                      selectedMedia.add({"id": entity.id, "file": file});
                    }

                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: AssetEntityImage(
                      entity,
                      fit: BoxFit.cover,
                      key: ValueKey<int>(index - 1),

                      thumbnailFormat: ThumbnailFormat.jpeg, //
                    ),
                  ),
                ),
                if (selectedMedia.isNotEmpty)
                  Positioned(
                      top: 10,
                      left: screenSize(context).width * 0.23,
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            shape: BoxShape.circle,
                            color: Colors.transparent),
                        child: Center(
                          child: Text(
                            id != -1 ? (id + 1).toString() : "",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ))
              ],
            );
          }
        },
        childCount: _entities!.length + 1,
        findChildIndexCallback: (Key key) {
          if (key is ValueKey<int>) {
            return key.value;
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Palette.primaryColorLight,
          centerTitle: true,
          title: Text(
            'Add Marketsquare',
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(fontWeight: FontWeight.normal),
          ),
        ),
        body: _marketSquareWidget(context));
  }

  _marketSquareWidget(context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Recents",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Icon(Icons.keyboard_arrow_down)
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment(
                        0.1, 0.0), // 10% of the width, so there are ten blinds.
                    colors: selectedMedia.isNotEmpty
                        ? <Color>[
                            Color(0xffee0000),
                            Palette.primaryColor,
                            Color.fromARGB(255, 240, 102, 11),
                          ]
                        : [
                            Colors.red.shade50,
                            Colors.red.shade50
                          ], // red to yellow
                  ),
                ),
                child: ClipRRect(
                  // borderRadius: BorderRadius.circular(10),
                  child: TextButton(
                    style: ElevatedButton.styleFrom(
                      enableFeedback: true,
                      padding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    ),
                    onPressed: () {},
                    child: Text(
                      "Select",
                      style: TextStyle(
                          color: selectedMedia.isNotEmpty
                              ? Colors.white
                              : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "You have given the Owlet access to a selected number of photos and videos.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              Text(
                "Manage",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Expanded(child: _buildImageGrid(context))
      ],
    );
  }
}
