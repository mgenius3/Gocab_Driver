import 'package:Driver/Assistants/assistant_method.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../infoHandler/app_info.dart';
import '../../global/global.dart';
import '../sub_screens/trips_history_screen.dart';

class EarningsTabPage extends StatefulWidget {
  const EarningsTabPage({super.key});

  @override
  State<EarningsTabPage> createState() => _EarningsTabPageState();
}

class _EarningsTabPageState extends State<EarningsTabPage> {
  @override
  void initState() {
    AssistantMethods.readDriverEarnings(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black,
        child: Column(
          children: [
            //earning

            Container(
              // color: Colors.lightBlue,
              width: double.infinity,
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Column(
                    children: [
                      const Text("Your Earnings",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      SizedBox(height: 10),
                      Text(
                          "\u20A6" +
                              Provider.of<AppInfo>(context, listen: false)
                                  .driverTotalEarnings,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                          ))
                    ],
                  )),
            ),
            //Total Number of trips

            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(context,
            //         MaterialPageRoute(builder: (c) => TripsHistoryScreen()));
            //   },
            //   style: ElevatedButton.styleFrom(
            //     primary: Colors.white54,
            //   ),
            //   child:
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                color: Colors.white54,
                child: Row(
                  children: [
                    Image.asset(
                      onlineDriverData.car_type == "Taxi"
                          ? "images/car.png"
                          : "images/bike.png",
                      width: 20,
                    ),
                    const SizedBox(width: 10),
                    const Text("Trips Completed",
                        style: TextStyle(color: Colors.black54)),
                    Expanded(
                      child: Container(
                        child: Text(
                            Provider.of<AppInfo>(context, listen: false)
                                .countTotalTrips
                                .toString(),
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ),
                    )
                  ],
                )),
            // )
          ],
        ));
  }
}
