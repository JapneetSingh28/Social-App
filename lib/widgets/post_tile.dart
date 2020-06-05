import 'package:flutter/material.dart';
import 'package:social_networking/pages/post_screen.dart';
import 'package:social_networking/widgets/custom_image.dart';
import 'package:social_networking/widgets/post.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);

  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: post.postId,
          userId: post.ownerId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String decp= '';
    if(post.description.length>10){
      decp=post?.description?.substring(0,8);
    }else{
      decp=post?.description;
    }
    return GestureDetector(
      onTap: () => showPost(context),
      child: Container(
//        color: Colors.grey[200],
        child: Column(
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                child:cachedNetworkImage(post.mediaUrl),
              ),
            ),
//          cachedNetworkImage(post.mediaUrl),
            Text(decp,style: TextStyle(fontSize: 10),softWrap: true,
              overflow: TextOverflow.clip,),
          ],
        ),
      ),
    );
  }
}
