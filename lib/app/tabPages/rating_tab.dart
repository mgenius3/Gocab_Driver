import 'package:Driver/Assistants/assistant_method.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../infoHandler/app_info.dart';
import '../../global/global.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

class RatingsTabPage extends StatefulWidget {
  const RatingsTabPage({super.key});

  @override
  State<RatingsTabPage> createState() => _RatingsTabPageState();
}

class _RatingsTabPageState extends State<RatingsTabPage> {
  double ratingNumber = 0;

  @override
  void initState() {
    AssistantMethods.readDriverRatings(context);
    getRatingsNumber();
    super.initState();
  }

  getRatingsNumber() {
    setState(() {
      ratingNumber = double.parse(
          Provider.of<AppInfo>(context, listen: false).driverAverageRatings);
    });

    setupRatingsTitle();
  }

  setupRatingsTitle() {
    if (ratingNumber >= 0) {
      setState(() {
        titleStarsRating = "Very Bad";
      });
    }
    if (ratingNumber >= 1) {
      setState(() {
        titleStarsRating = "Bad";
      });
    }
    if (ratingNumber >= 2) {
      setState(() {
        titleStarsRating = "Good";
      });
    }
    if (ratingNumber >= 3) {
      setState(() {
        titleStarsRating = "Very Good";
      });
    }
    if (ratingNumber >= 4) {
      setState(() {
        titleStarsRating = "Excellent";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white60,
        child: Container(
            margin: EdgeInsets.all(4),
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white54, borderRadius: BorderRadius.circular(15)),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                height: 22.0,
              ),
              Text("My Ratings",
                  style: TextStyle(
                    fontSize: 22,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  )),
              SizedBox(height: 20),
              SmoothStarRating(
                rating: ratingNumber,
                allowHalfRating: true,
                starCount: 5,
                color: Colors.blue,
                borderColor: Colors.blue,
                size: 40,
              ),
              SizedBox(
                height: 12.0,
              ),
              Text(titleStarsRating,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  )),
              SizedBox(
                height: 18.0,
              ),
            ])),
      ),
    );
  }
}
