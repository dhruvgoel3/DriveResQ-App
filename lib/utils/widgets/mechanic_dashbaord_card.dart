import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../modules/mechanic/views/request_detail_view.dart';

class RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;

  const RequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(request['problem'] ?? "Problem not specified"),

        subtitle: Text(
          "${request['vehicleType']} • ${request['locationName']}\n${request['distance']} km away",
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          Get.to(() => RequestDetailView(request: request));
        },
      ),
    );
  }
}
