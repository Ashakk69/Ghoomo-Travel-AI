import 'package:share_plus/share_plus.dart';
import '../models/destination.dart';

class ShareService {
  static Future<void> shareDestination(Destination destination) async {
    final String text =
        'Check out this amazing trip to ${destination.name}, ${destination.country}!\n\n'
        'Estimated Cost: \$${destination.estimatedCost}\n'
        'Category: ${destination.category}\n\n'
        'Sent from Ghoomo - Your AI Travel Planner';

    await Share.share(text);
  }
}
