import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:owlet/Components/ProfileAvatar.dart';
import 'package:owlet/Components/ReadMore.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Providers/UtilsProvider.dart';
import 'package:owlet/Screens/Login.dart';
import 'package:owlet/Widgets/BottomModalLayout.dart';
import 'package:owlet/Widgets/ChatInputBar.dart';
import 'package:owlet/Widgets/LikeBtn.dart';
import 'package:owlet/Widgets/PullToRefresh.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/enum.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:owlet/modals/ProfileViewModal.dart';
import 'package:owlet/models/Comment.dart';
import 'package:owlet/models/HttpResponse.dart';
import 'package:owlet/models/Listing.dart';
import 'package:owlet/services/apiUrl.dart';
import 'package:owlet/services/comment.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../Providers/GlobalProvider.dart';
import '../Providers/Listing.dart';

class ListingCommentModal extends StatefulWidget {
  static var show =
      (BuildContext ctx, Listing post) => showCupertinoModalBottomSheet(
            context: ctx,
            builder: (context) => Container(
              child: ListingCommentModal(post: post),
            ),
            duration: Duration(milliseconds: 400),
            expand: false,
            barrierColor: Colors.black.withOpacity(0.4),
          );
  final Listing post;
  const ListingCommentModal({required this.post});

  @override
  State<ListingCommentModal> createState() => _ListingCommentModalState();
}

class _ListingCommentModalState extends State<ListingCommentModal> {
  bool loading = true;
  Comment? commentToReply;

  @override
  void initState() {
    Future.delayed(Duration.zero, init);
    super.initState();
  }

  init() async {
    if (widget.post.commentsData.comments.length < 1) {
      await loadComments(refresh: true);
    } else
      setState(() => loading = false);
  }

  loadComments({bool refresh = false, int? parentId}) async {
    try {
      final comData = widget.post.commentsData;

      widget.post.commentsData.setCommentsData = await fetchComments(
        CommentableType.LISTING,
        widget.post.id,
        refresh ? 0 : comData.currentPage + 1,
        parentId: parentId,
      );
    } catch (err) {
      print(err);
      Toast(context, message: 'An error occured while fetching comments')
          .show();
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = GlobalProvider(context);
    Provider.of<ListingProvider>(context);
    final userData = Provider.of<UserProvider>(context);
    final post = widget.post;
    void postComment(String msg) async {
      if (userData.isLoggedIn) {
        final parentId = commentToReply?.parentId ?? commentToReply?.id ?? null;

        final message = commentToReply?.parentId == null
            ? msg
            : '@${commentToReply!.author.username} ' + msg;

        if (msg.length > 0) {
          if (commentToReply != null)
            (commentToReply!.parentId != null
                    ? widget.post.commentsData.comments
                        .firstWhere((_) => _.id == commentToReply!.parentId)
                    : commentToReply!)
                .replyData!
                .newComment = Comment(
              message: message,
              author: userData.profile,
              createdAt: DateTime.now().toString(),
              commentableId: post.id,
              parentId: parentId,
            );
          else
            widget.post.commentsData.newComment = Comment(
                message: msg,
                author: userData.profile,
                createdAt: DateTime.now().toString(),
                commentableId: post.id,
                replyData: CommentResponse(
                  totalItems: 0,
                  comments: [],
                  totalPages: 0,
                  currentPage: -1,
                ));

          setState(() {});
          var res =
              await post.postComment(message, post.id, parentId: parentId);
          if (res['status']) {
            commentToReply = null;
          } else
            widget.post.commentsData.comments.first.id = 0;
          state.addcomments = post.id;
          setState(() {});
        }
      } else
        Navigator.pushNamed(context, LoginScreen.routeName);
    }

    return BottomModalLayout(children: [
      Padding(
        padding: const EdgeInsets.all(7.0),
        child: WithPreloader(
          loading: widget.post == null,
          child: Column(
            children: [
              Container(
                constraints: BoxConstraints(
                  maxHeight: context.screenHeight * 0.72 -
                      MediaQuery.of(context).viewInsets.bottom -
                      MediaQuery.of(context).viewInsets.top,
                ),
                child: PullToLoad(
                  refresh: () => loadComments(refresh: true),
                  load: () => loadComments(),
                  child: ListView.builder(
                    itemCount:
                        loading ? 10 : 2 + post.commentsData.comments.length,
                    itemBuilder: (_, i) {
                      final commentData = widget.post.commentsData;
                      return i == 0
                          ? Row(
                              children: [
                                ProfileAvatar(
                                    avatar: post.owner.avtar,
                                    size: 60,
                                    isOnline: post.owner.isOnline,
                                    withBorder: true,
                                    onPressed: () async {
                                      ProfileViewModal.show(context);
                                      await Provider.of<UtilsProvider>(context,
                                              listen: false)
                                          .getCurrentProfileFromUsername(
                                              post.owner.username);
                                    }),
                                10.widthBox,
                                VxBox(
                                  child: ReadMore(
                                    caption: post.caption,
                                    username: post.owner.username,
                                    maxLength: 120,
                                  ),
                                ).make().expand(),
                              ],
                            )
                          : i == 1
                              ? Divider(height: 1).py8()
                              : loading
                                  ? CommentItemPreloader()
                                  : CommentItem(
                                      onLike: (_) =>
                                          commentData.comments[i - 2].iLike
                                              ? commentData.unLike(
                                                  commentData.comments[i - 2])
                                              : commentData.like(
                                                  commentData.comments[i - 2]),
                                      comment: commentData.comments[i - 2],
                                      onReply: (_) =>
                                          setState(() => commentToReply = _),
                                    );
                    },
                  ),
                ),
              ),
              Column(
                children: [
                  if (commentToReply != null)
                    VxBox(
                      child: Column(
                        children: [
                          VxBox(
                            child: HStack(
                              [
                                ReadMore(
                                  caption: commentToReply!.message,
                                  username: commentToReply!.author.username,
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Vx.gray500,
                                    fontSize: 10,
                                  ),
                                  showReadmore: false,
                                ).expand(),
                                Icon(
                                  Icons.close,
                                  size: 16,
                                ).onInkTap(() =>
                                    setState(() => commentToReply = null)),
                              ],
                            ),
                          )
                              .padding(EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ))
                              .topRounded()
                              .width(context.screenWidth * 1)
                              .color(Vx.gray100)
                              .make(),
                          Divider(
                            indent: 0,
                            endIndent: 0,
                            height: 0,
                            thickness: 0.7,
                            color: Palette.primaryColor,
                          ),
                        ],
                      ),
                    ).make(),
                  Row(
                    children: [
                      ProfileAvatar(
                        avatar: userData.profile.avtar,
                        size: 42,
                      ),
                      8.widthBox,
                      ChatInputBar(
                        onSend: postComment,
                        hint: commentToReply != null
                            ? 'Replying ${commentToReply!.author.username}'
                            : 'Enter comment...',
                      ).expand()
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}

class CommentItem extends StatefulWidget {
  final Comment comment;
  final Function(Comment)? onReply;
  final Future<bool?> Function(bool) onLike;

  const CommentItem({
    Key? key,
    required this.comment,
    this.onReply,
    required this.onLike,
  }) : super(key: key);

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool reply = false;

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context);
    return VxBox(
      child: VStack(
        [
          HStack(
            [
              if (widget.comment.id == null)
                Icon(
                  Icons.timelapse_outlined,
                  size: 12,
                ).shimmer(
                  primaryColor: Vx.gray300,
                  secondaryColor: Vx.gray200,
                )
              else if (widget.comment.id == 0)
                Icon(
                  Icons.error_outline,
                  size: 12,
                  color: Vx.red900,
                ),
              ProfileAvatar(
                  align: Alignment.topCenter,
                  avatar: widget.comment.author.avtar,
                  size: widget.comment.parentId == null ? 45 : 30,
                  onPressed: () async {
                    ProfileViewModal.show(context);
                    await Provider.of<UtilsProvider>(context, listen: false)
                        .getCurrentProfileFromUsername(
                            widget.comment.author.username);
                  }),
              7.widthBox,
              VStack(
                [
                  HStack(
                    [
                      VStack(
                        [
                          ReadMore(
                            caption: widget.comment.message,
                            username: widget.comment.author.username,
                            maxLength: 120,
                          ),
                          5.heightBox,
                          HStack(
                            [
                              timeAgo(widget.comment.createdAt)
                                  .text
                                  .color(Vx.gray400)
                                  .size(10)
                                  .make(),
                              12.widthBox,
                              ...(widget.comment.totalLikes > 1
                                  ? [
                                      '${widget.comment.totalLikes} likes'
                                          .text
                                          .color(Vx.gray400)
                                          .size(10)
                                          .make(),
                                      12.widthBox,
                                    ]
                                  : []),
                              'Reply'
                                  .text
                                  .color(Vx.gray400)
                                  .size(10)
                                  .make()
                                  .onInkTap(() => widget.onReply != null
                                      ? widget.onReply!(widget.comment)
                                      : null),
                              12.widthBox,
                              if (widget.comment.totalReplies > 0 &&
                                  widget.comment.remainingRepliesCount > 0)
                                'View ${widget.comment.remainingRepliesCount}${widget.comment.fetchedRepliesCount > 0 ? " more" : ""} replies'
                                    .text
                                    .italic
                                    .color(Vx.gray400)
                                    .size(10)
                                    .make()
                                    .onInkTap(() async {
                                  widget.comment
                                      .loadReplies(CommentableType.LISTING)
                                      .then((value) => setState(() {}));
                                })
                            ],
                          )
                        ],
                      ).expand(),
                      7.widthBox,
                      LikeBtn(
                        isLiked: widget.comment.iLike,
                        onLike: (liked) => liked && widget.comment.iLike
                            ? widget.onLike(false)
                            : widget.onLike(true),
                        size: 16,
                        icon: CupertinoIcons.heart,
                      ).py16()
                    ],
                    crossAlignment: CrossAxisAlignment.start,
                  ),
                  if (widget.comment.replyData != null &&
                      widget.comment.replyData!.comments.length > 0)
                    VStack(
                      widget.comment.replyData!.comments
                          .map((c) => CommentItem(
                                onLike: (_) => c.iLike
                                    ? widget.comment.replyData!.unLike(c)
                                    : widget.comment.replyData!.like(c),
                                comment: c,
                                onReply: widget.onReply,
                              ))
                          .toList(),
                    )
                ],
              ).expand(),
            ],
            crossAlignment: CrossAxisAlignment.start,
          ),
        ],
      ),
    ).py4.make();
  }
}

class CommentItemPreloader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return VxBox(
      child: VStack(
        [
          HStack(
            [
              VxCircle(
                backgroundColor: Vx.gray300,
                radius: 45,
              ).shimmer(primaryColor: Vx.gray200, secondaryColor: Vx.gray300),
              7.widthBox,
              VStack(
                [
                  HStack(
                    [
                      VStack(
                        [
                          VStack(
                            [
                              VxBox()
                                  .color(Vx.gray300)
                                  .height(16)
                                  .roundedSM
                                  .p8
                                  .make()
                                  .shimmer(
                                      primaryColor: Vx.gray200,
                                      secondaryColor: Vx.gray300),
                              3.heightBox,
                              VxBox()
                                  .color(Vx.gray300)
                                  .height(16)
                                  .width(170)
                                  .roundedSM
                                  .p8
                                  .make()
                                  .shimmer(
                                      primaryColor: Vx.gray200,
                                      secondaryColor: Vx.gray300),
                            ],
                          ),
                          5.heightBox,
                          HStack(
                            [
                              VxBox()
                                  .px16
                                  .height(12)
                                  .roundedSM
                                  .color(Vx.gray300)
                                  .make()
                                  .shimmer(
                                      primaryColor: Vx.gray200,
                                      secondaryColor: Vx.gray300),
                              12.widthBox,
                              VxBox()
                                  .px16
                                  .height(12)
                                  .roundedSM
                                  .color(Vx.gray300)
                                  .make()
                                  .shimmer(
                                      primaryColor: Vx.gray200,
                                      secondaryColor: Vx.gray300),
                              12.widthBox,
                              VxBox()
                                  .px16
                                  .height(12)
                                  .roundedSM
                                  .color(Vx.gray300)
                                  .make()
                                  .shimmer(
                                      primaryColor: Vx.gray200,
                                      secondaryColor: Vx.gray300),
                            ],
                          )
                        ],
                      ).expand(),
                      7.widthBox,
                      SizedBox(
                        child: Icon(
                          CupertinoIcons.heart_fill,
                          size: 16,
                          color: Vx.gray300,
                        ),
                      ).py16().shimmer(
                          primaryColor: Vx.gray200, secondaryColor: Vx.gray300),
                    ],
                    crossAlignment: CrossAxisAlignment.start,
                  ),
                ],
              ).expand(),
            ],
            crossAlignment: CrossAxisAlignment.start,
          )
        ],
      ),
    ).py4.make();
  }
}

class WithPreloader extends StatelessWidget {
  const WithPreloader({
    required this.child,
    required this.loading,
  });
  final Widget child;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: loading ? CupertinoActivityIndicator() : child,
    );
  }
}
