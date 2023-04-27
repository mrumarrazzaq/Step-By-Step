import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:stepbystep/colors.dart';

class ImageMessage extends StatelessWidget {
  const ImageMessage({
    Key? key,
    required this.imageUrl,
    required this.time,
    required this.messageStatus,
    required this.left,
    required this.right,
    required this.onTap,
    required this.color,
  }) : super(key: key);
  final Function() onTap;
  final String imageUrl;
  final String time;
  final int messageStatus;
  final Color? color;
  final double left;
  final double right;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.0),
        ),
        margin: const EdgeInsets.all(5.0),
        padding:
            EdgeInsets.only(left: left, right: right, top: 5.0, bottom: 5.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(
                        value: downloadProgress.progress,
                        color: AppColor.white),
                errorWidget: (context, url, error) =>
                    Icon(Icons.error, color: AppColor.white),
              ),
            ),
            Row(
              mainAxisAlignment:
                  left == 100 ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: AppColor.grey),
                ),
                Icon(messageStatus == 0 ? Icons.check : Icons.access_time_sharp,
                    size: 15, color: Colors.grey[400]),
                const SizedBox(width: 3),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
