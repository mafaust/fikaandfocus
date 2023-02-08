import 'package:fika_and_fokus/widgets/DirectionButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/CafeModel.dart';
import '../widgets/Heart.dart';
import '../widgets/ReviewDialog.dart';
import '../models/ReviewModel.dart';
import '../models/UserModel.dart';

//ignore: must_be_immutable
class CafePage extends StatefulWidget {
  final CafeModel cafeItem;
  UserModel user = UserModel(userName: "default", email: "", password: "");

  CafePage(this.cafeItem, this.user, {Key? key}) : super(key: key);

  @override
  State<CafePage> createState() => _CafePageState();
}

class _CafePageState extends State<CafePage> {
  var reviews = [];

  @override
  void initState() {
    refreshReviews();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.cafeItem.buildPrice(context).data;
    return Scaffold(
      backgroundColor: const Color(0xFFE0DBCF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refreshReviews,
          child: CustomScrollView(slivers: [
            SliverAppBar(
              expandedHeight: 300,
              backgroundColor: const Color(0xFF75AB98),
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  widget.cafeItem.name,
                  style: GoogleFonts.oswald(
                    color: const Color(0xFFFFFFFF),
                    fontWeight: FontWeight.w300),
                ),
                background: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 15,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              color: Colors.black54,
                              spreadRadius: 3)
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 110,
                          backgroundImage: AssetImage("images/test_cafe.jpg")
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                      child: IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.cafeItem.address,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.oswald(
                                fontSize: 16,
                                letterSpacing: 0.6,
                                color: const Color(0xFF696969),
                                fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      decoration: BoxDecoration(
                        color: const Color(0x22696969),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.cafeItem.rating.toString(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                fontSize: 25,
                                color: Colors.white,
                                fontWeight: FontWeight.normal),
                            ),
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 25,
                            ),
                            const VerticalDivider(
                              width: 20,
                              indent: 20,
                              endIndent: 20,
                              thickness: 1,
                              color: Color(0xFF696969)),
                            Text(
                              _changePriceStringToDollarSign(),
                              style: GoogleFonts.roboto(
                                fontSize: 25,
                                color: Colors.white,
                                fontWeight: FontWeight.normal),
                            ),
                            const VerticalDivider(
                              width: 20,
                              indent: 20,
                              endIndent: 20,
                              thickness: 1,
                              color: Color(0xFF696969)),
                            Transform.scale(
                              scale: 0.6,
                              child: DirectionButton(
                                currentCafe: widget.cafeItem),
                            ),
                            const VerticalDivider(
                              width: 20,
                              indent: 20,
                              endIndent: 20,
                              thickness: 1,
                              color: Color(0xFF696969)),
                            Transform.scale(
                              scale: 0.6,
                              child: Heart(
                                currentCafe: widget.cafeItem,
                                user: widget.user)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ElevatedButton(
                      onPressed: () async {
                        ReviewDialogResult? result = await showDialog(
                          context: context,
                          builder: (_) => ReviewDialog(widget.cafeItem));
                        if (result == null) {
                          return;
                        } else {
                          createReview(
                            result.rating, result.review, result.hideName);
                        }
                      },
                      child: Text(
                        'RATE THIS CAFÉ',
                        style: GoogleFonts.oswald(
                          color: const Color(0xFFFFFFFF),
                          fontSize: 18,
                          fontWeight: FontWeight.normal),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xFF696969),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0DBCF),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        decoration: _getBoxStyle(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            ListTile(
                              leading: const CircleAvatar(
                                radius: 10,
                                backgroundImage:
                                  AssetImage('images/profile_picture.png'),
                              ),
                              title: reviews[index].buildUser(context),
                              trailing: reviews[index].buildDate(context),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: RatingBarIndicator(
                                rating: reviews[index].buildRating(context),
                                direction: Axis.horizontal,
                                itemCount: 5,
                                itemSize: 10.0,
                                itemPadding:
                                  const EdgeInsets.fromLTRB(0, 0, 4, 5),
                                itemBuilder: (context, _) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                            Container(
                              margin:
                                const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: reviews[index].buildReview(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: reviews.length,
              ),
            )
          ]),
        ),
      ),
    );
  }

  Future<ReviewModel> createReview(double rating, String review, bool hideName)
  async {
    String emailToPost = "anonymous";
    if (!hideName) emailToPost = widget.user.getEmail;

    Uri newReview = Uri.parse(
      'https://group-1-75.pvt.dsv.su.se/fikafocus-0.0.1-SNAPSHOT/reviews/add?'
      'rating=${rating.toString()}'
      '&reviewText=$review'
      '&cafeId=${widget.cafeItem.id}'
      '&userEmail=$emailToPost');

    final response = await http.post(newReview);

    if (response.statusCode == 200) {
      return ReviewModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Failed to create review.  ' + response.statusCode.toString());
    }
  }

  Future refreshReviews() async {
    Uri reviewsURI = Uri.parse(
      'https://group-1-75.pvt.dsv.su.se/fikafocus-0.0.1-SNAPSHOT/cafes/${widget.cafeItem.id}/all');

    final response = await http.get(reviewsURI);

    if (response.statusCode == 200) {
      String source = const Utf8Decoder().convert(response.bodyBytes);
      var data = json.decode(source);

      reviews = [];
      var _reviewsTemp = [];
      for (var i = 0; i < data.length; i++) {
        _reviewsTemp.add(ReviewModel.fromJson(data[i]));
      }

      _reviewsTemp.sort((a, b) => (b.id) - (a.id));

      setState(() {
        reviews = _reviewsTemp;
      });
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  BoxDecoration _getBoxStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 5,
          blurRadius: 7,
          offset: const Offset(2, 3))
      ]
    );
  }

  String _changePriceStringToDollarSign() {
    switch (widget.cafeItem.price) {
      case "0":
        return 'N/A';
      case "1":
        return '\$';
      case "2":
        return '\$\$';
      case "3":
        return '\$\$\$';
    }
    return widget.cafeItem.price;
  }
}
