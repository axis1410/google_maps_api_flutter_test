import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:google_maps_api_flutter_test/location_dashboard.dart';

import '../models/user_model.dart';
import 'auth/authenticate.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    // return either the Home or Authenticate widget
    if (user == null) {
      return const Authenticate();
    } else {
      return const LocationDashboard();
    }
  }
}
