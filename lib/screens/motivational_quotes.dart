import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readmore/readmore.dart';
import 'package:stepbystep/colors.dart';

class MotivationalQuotes extends StatefulWidget {
  const MotivationalQuotes({Key? key}) : super(key: key);

  @override
  State<MotivationalQuotes> createState() => _MotivationalQuotesState();
}

class _MotivationalQuotesState extends State<MotivationalQuotes> {
  late final quotesData;

  int totalQuotes = 0;
  List<String> quoteImages = [];
  List<String> quoteText = [];
  bool loading = true;

  getQuotes() async {
    try {
      // Get docs from collection reference
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Quotes').get();

      // Get data from docs and convert map to List
      quotesData = querySnapshot.docs.map((doc) => doc.data()).toList();

      for (int i = 0; i < quotesData.length; i++) {
        quoteImages.add(quotesData[i]['image']);
        quoteText.add(quotesData[i]['text']);
      }
      setState(() {
        totalQuotes = quotesData.length;
        loading = false;
      });
      log('totalQuotes $totalQuotes');
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.orange,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Image.asset('assets/quotation-mark.png',
                height: MediaQuery.of(context).size.height * 0.1),
          ),
          Center(
            child: loading
                ? CircularProgressIndicator(
                    color: AppColor.orange,
                  )
                : CarouselSlider.builder(
                    itemCount: totalQuotes,
                    itemBuilder: (BuildContext context, int itemIndex,
                            int pageViewIndex) =>
                        SingleChildScrollView(
                      child: SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 2,
                          shadowColor: AppColor.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                clipBehavior: Clip.antiAlias,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(30.0),
                                  topRight: Radius.circular(30.0),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: quoteImages[itemIndex],
                                  width: double.infinity,
                                  maxWidthDiskCache: 500,
                                  maxHeightDiskCache: 500,
                                  placeholder: (context, url) => Container(
                                    height: 200,
                                    width: double.infinity,
                                    color: AppColor.white,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),

                                /*Image.network(
                                  quoteImages[itemIndex],
                                  width: double.infinity,
                                ),*/
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 18),
                                child: ReadMoreText(
                                  quoteText[itemIndex],

                                  trimLines: 6,
                                  colorClickableText: AppColor.orange,
                                  textAlign: TextAlign.justify,
                                  trimMode: TrimMode.Line,
                                  trimCollapsedText: '  more',
                                  trimExpandedText: '      less',
                                  moreStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.fade,
                                      color: AppColor.black),
                                  lessStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.black),
                                  //nerkoOne
                                  style: GoogleFonts.cookie(
                                    fontSize: 20,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    options: CarouselOptions(
                      autoPlay: false,
                      height: MediaQuery.of(context).size.height * 0.55,
                      clipBehavior: Clip.antiAlias,
                      enlargeCenterPage: true,
                      //aspectRatio: 2,
                      enableInfiniteScroll: false,
                    ),
                  ),
          ),
        ],
      ),

      // Container(
      //
      //   decoration: BoxDecoration(
      //     image: DecorationImage(
      //       alignment: Alignment.topCenter,
      //       image: AssetImage('assets/quotation-mark.png'),
      //     ),
      //   ),
      //   child:
      // ),
      // Image.asset('assets/quotation-mark.png'),
    );
  }
}
