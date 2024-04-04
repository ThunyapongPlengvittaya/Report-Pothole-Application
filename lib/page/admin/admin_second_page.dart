import 'package:flutter/material.dart';
import 'package:pothole_app/page/admin/Pothole/pothole_page.dart';
import 'package:pothole_app/page/admin/pothole/no_pothole_page.dart';

class AdminSecondPage extends StatelessWidget {
  const AdminSecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          body: Column(
            children: <Widget>[
              PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: TabBar(
                  tabs: [
                    Tab(text: 'Potholes'),
                    Tab(text: 'No Potholes'),
                  ],
                  indicatorColor: Colors.blue, // Set the indicator color here
                  labelColor: Colors
                      .blueAccent, // Set the text color of the selected tab
                  unselectedLabelColor: Color.fromARGB(255, 97, 97,
                      97), // Set the text color of the unselected tabs
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    PotholePage(),
                    NoPotholePage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
