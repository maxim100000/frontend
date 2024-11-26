import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:http/http.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      routerConfig: _router,
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 700) {
        return Scaffold(
          body: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: FractionallySizedBox(
                        widthFactor: 0.6,
                        child: SizedBox(
                          height: 70,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                  onPressed: () {}, child: const Text('Домой')),
                              ElevatedButton(
                                  onPressed: () {
                                    context.go('/about');
                                  },
                                  child: const Text('О нас'))
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 4,
                      child: Padding(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: TextField(
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(2)))),
                          maxLines: null,
                          expands: true,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: SizedBox(
                                    height: 50,
                                    width: 150,
                                    child: ElevatedButton(
                                        style: const ButtonStyle(
                                          elevation: WidgetStatePropertyAll(3),
                                        ),
                                        onPressed: () {},
                                        child: const Text('Получить')),
                                  ),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 15.0),
                                    child: ElevatedButton(
                                        style: const ButtonStyle(
                                            elevation:
                                                WidgetStatePropertyAll(3)),
                                        onPressed: () {},
                                        child: const Text('Отправить')),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const SizedBox(
                    height: 70,
                  ),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return SizedBox(
                            height: 150,
                            child: Card(
                                elevation: 3,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.red,
                                    child: Text('${index + 1}'),
                                  ),
                                  title: Text('Item ${index + 1}'),
                                  subtitle: Text('Item ${index + 1}'),
                                )),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 90,
                  )
                ],
              ),
            ],
          ),
        );
      } else {
        return PageView(
          scrollDirection: Axis.vertical,
          children: const [
            TextArea(),
            ListOfCitates(),
          ],
        );
      }
    });
  }
}

class ListOfCitates extends StatelessWidget {
  const ListOfCitates({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 70,
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return SizedBox(
                    height: 150,
                    child: Card(
                        elevation: 3,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Text('${index + 1}'),
                          ),
                          title: Text('Item ${index + 1}'),
                          subtitle: Text('Item ${index + 1}'),
                        )),
                  );
                },
              ),
            ),
          ),
          const SizedBox(
            height: 90,
          )
        ],
      ),
    );
  }
}

class TextArea extends StatelessWidget {
  const TextArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: FractionallySizedBox(
              widthFactor: 0.6,
              child: SizedBox(
                height: 70,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        onPressed: () {}, child: const Text('Домой')),
                    ElevatedButton(
                        onPressed: () {
                          context.go('/about');
                        },
                        child: const Text('О нас'))
                  ],
                ),
              ),
            ),
          ),
          const Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: TextField(
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(2)))),
                maxLines: null,
                expands: true,
              ),
            ),
          ),
          SizedBox(
            height: 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: SizedBox(
                          height: 50,
                          width: 150,
                          child: ElevatedButton(
                              style: const ButtonStyle(
                                elevation: WidgetStatePropertyAll(3),
                              ),
                              onPressed: () {},
                              child: const Text('Получить')),
                        ),
                      ),
                      const Icon(Icons.arrow_downward),
                      SizedBox(
                        width: 150,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: ElevatedButton(
                              style: const ButtonStyle(
                                  elevation: WidgetStatePropertyAll(3)),
                              onPressed: () {},
                              child: const Text('Отправить')),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: FractionallySizedBox(
              widthFactor: 0.6,
              child: SizedBox(
                height: 70,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          context.go('/');
                        },
                        child: const Text('Домой')),
                    ElevatedButton(onPressed: () {}, child: const Text('О нас'))
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(margin: const EdgeInsets.all(15), child: const MapScreen()),
          )
        ],
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController mapController;

  List<LatLng> get points => [
        const LatLng(55.755793, 37.617134),
        const LatLng(55.095960, 38.765519),
        const LatLng(56.129038, 40.406502),
        const LatLng(54.513645, 36.261268),
        const LatLng(54.193122, 37.617177),
        const LatLng(54.629540, 39.741809),
      ];

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
        mapController: mapController,
        options: const MapOptions(
            initialCenter: LatLng(55.001384376866994, 82.89789852236267),
            initialZoom: 6),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.flutter_map_example',
            tileProvider: CancellableNetworkTileProvider(),
          ),
          const MarkerLayer(markers: [
            Marker(
              width: 80,
              height: 80,
              point: LatLng(55.001384376866994, 82.89789852236267),
              child: Icon(Icons.location_on, color: Colors.red),
            ),
          ]),
        ]);
  }
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MyHomePage(title: 'Главная'),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const MapView(),
    )
  ],
);

Future<Response> getJsonData() async => get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));