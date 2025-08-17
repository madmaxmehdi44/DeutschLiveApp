// // screens/home_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/channel_provider.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen();

//   @override
//   Widget build(BuildContext context) {
//     final prov = context.watch<ChannelProvider>();

//     return Scaffold(
//       appBar: AppBar(
//         title: TextField(
//           decoration: const InputDecoration(
//             hintText: 'جست‌وجوی شبکه...',
//             border: InputBorder.none,
//             prefixIcon: Icon(Icons.search),
//           ),
//           onChanged: prov.updateSearch,
//         ),
//       ),
//       body: ListView.builder(
//         itemCount: prov.filtered.length,
//         itemBuilder: (context, i) {
//           final ch = prov.filtered[i];
//           return ListTile(
//             leading: Image.network(ch.logoUrl),
//             title: Text(ch.name),
//             trailing: IconButton(
//               icon: Icon(
//                 prov.isFav(ch.id) ? Icons.star : Icons.star_border,
//                 color: prov.isFav(ch.id) ? Colors.amber : null,
//               ),
//               onPressed: () => prov.toggleFav(ch.id),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }