import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:readmore/readmore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:stepbystep/colors.dart';
import 'package:stepbystep/api_keys/api_keys.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

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

  List<dynamic> _photos = [];

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

  final String apiUrl = 'https://api.pexels.com/v1/search?query=motivation';

  getImages() {
    http.get(Uri.parse(apiUrl), headers: {'Authorization': pexelAPIKey}).then(
        (response) {
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          _photos = data['photos'];
          log(_photos.toString());
          loading = false;
        });
      } else {
        log('API request failed with status code ${response.statusCode}');
      }
    });
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
      body:
          // Stack(
          //   alignment: Alignment.topCenter,
          //   children: [
          //     Positioned.fill(
          //       top: -450,
          //       child: Stack(
          //         children: [
          //           Align(
          //             alignment: Alignment.center,
          //             child: Lottie.asset(
          //                 height: 120, 'animations/rotating-circle.json'),
          //           ),
          //           Align(
          //             alignment: Alignment.center,
          //             child: Image.asset('assets/quotation-mark.png',
          //                 height: MediaQuery.of(context).size.height * 0.1),
          //           ),
          //         ],
          //       ),
          //     ),
          //     Center(
          //       child: loading
          //           ? CircularProgressIndicator(
          //               color: AppColor.orange,
          //             )
          //           : Padding(
          //               padding: const EdgeInsets.only(top: 100),
          //               child: CarouselSlider.builder(
          //                 itemCount: _photos.length,
          //                 itemBuilder: (BuildContext context, int itemIndex,
          //                         int pageViewIndex) =>
          //                     SingleChildScrollView(
          //                   child: Padding(
          //                     padding: const EdgeInsets.only(top: 20.0),
          //                     child: SizedBox(
          //                       width: double.infinity,
          //                       child: Card(
          //                         elevation: 2,
          //                         shadowColor: AppColor.grey,
          //                         shape: RoundedRectangleBorder(
          //                           borderRadius: BorderRadius.circular(30.0),
          //                         ),
          //                         margin: const EdgeInsets.symmetric(vertical: 5),
          //                         child: Column(
          //                           mainAxisSize: MainAxisSize.min,
          //                           crossAxisAlignment: CrossAxisAlignment.center,
          //                           children: [
          //                             ClipRRect(
          //                               clipBehavior: Clip.antiAlias,
          //                               borderRadius: const BorderRadius.only(
          //                                 topLeft: Radius.circular(30.0),
          //                                 topRight: Radius.circular(30.0),
          //                               ),
          //                               child: CachedNetworkImage(
          //                                 imageUrl: _photos[itemIndex]['src']
          //                                     ['landscape'],
          //                                 width: double.infinity,
          //                                 maxWidthDiskCache: 500,
          //                                 maxHeightDiskCache: 500,
          //                                 placeholder: (context, url) => Container(
          //                                   height: 150,
          //                                   width: double.infinity,
          //                                   color: AppColor.white,
          //                                 ),
          //                                 errorWidget: (context, url, error) =>
          //                                     const Icon(Icons.error),
          //                               ),
          //
          //                               /*Image.network(
          //                                 quoteImages[itemIndex],
          //                                 width: double.infinity,
          //                               ),*/
          //                             ),
          //                             Container(
          //                               margin: const EdgeInsets.symmetric(
          //                                   vertical: 5, horizontal: 18),
          //                               child: ReadMoreText(
          //                                 _photos[itemIndex]['height'].toString(),
          //
          //                                 trimLines: 6,
          //                                 colorClickableText: AppColor.orange,
          //                                 textAlign: TextAlign.justify,
          //                                 trimMode: TrimMode.Line,
          //                                 trimCollapsedText: '  more',
          //                                 trimExpandedText: '      less',
          //                                 moreStyle: TextStyle(
          //                                     fontSize: 12,
          //                                     fontWeight: FontWeight.bold,
          //                                     overflow: TextOverflow.fade,
          //                                     color: AppColor.black),
          //                                 lessStyle: TextStyle(
          //                                     fontSize: 12,
          //                                     fontWeight: FontWeight.bold,
          //                                     color: AppColor.black),
          //                                 //nerkoOne
          //                                 style: GoogleFonts.cookie(
          //                                   fontSize: 20,
          //                                   fontStyle: FontStyle.italic,
          //                                 ),
          //                               ),
          //                             ),
          //                           ],
          //                         ),
          //                       ),
          //                     ),
          //                   ),
          //                 ),
          //                 options: CarouselOptions(
          //                   autoPlay: false,
          //                   height: MediaQuery.of(context).size.height * 0.55,
          //                   clipBehavior: Clip.antiAlias,
          //                   enlargeCenterPage: true,
          //                   //aspectRatio: 2,
          //                   enableInfiniteScroll: false,
          //                 ),
          //               ),
          //             ),
          //     ),
          //   ],
          // ),
          Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            top: -450,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Lottie.asset(
                      height: 120, 'animations/rotating-circle.json'),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Image.asset('assets/quotation-mark.png',
                      height: MediaQuery.of(context).size.height * 0.1),
                ),
              ],
            ),
          ),
          Center(
            child: loading
                ? CircularProgressIndicator(
                    color: AppColor.orange,
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: CarouselSlider.builder(
                      itemCount: totalQuotes,
                      itemBuilder: (BuildContext context, int itemIndex,
                              int pageViewIndex) =>
                          SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20.0),
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
