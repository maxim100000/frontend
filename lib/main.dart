import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:http/http.dart';
import 'package:idb_shim/idb_browser.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await deleteDatabase();
  await initializeDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
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
                      child: SizedBox(
                        height: 70,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const ElevatedButton(
                                onPressed: null,
                                style: ButtonStyle(
                                    elevation: WidgetStatePropertyAll(3),
                                    shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                      Radius.circular(3),
                                    )))),
                                child: Text('Домой')),
                            ElevatedButton(
                                style: const ButtonStyle(
                                    elevation: WidgetStatePropertyAll(3),
                                    shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                      Radius.circular(3),
                                    )))),
                                onPressed: () {
                                  context.go('/about');
                                },
                                child: const Text('О нас'))
                          ],
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
                                            elevation:
                                                WidgetStatePropertyAll(3),
                                            shape: WidgetStatePropertyAll(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                3))))),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                const Dialog(),
                                          );
                                        },
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
                                                WidgetStatePropertyAll(3),
                                            shape: WidgetStatePropertyAll(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                3))))),
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
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 70,
                    ),
                    Flexible(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            return SizedBox(
                              height: 150,
                              child: Card(
                                  elevation: 3, child: Center(child: Text(''))),
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
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: FutureBuilder(
                future: getAllRecords(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              deleteLocalRecord(snapshot.data![index]['id']);
                            } else if (direction ==
                                DismissDirection.startToEnd) {
                              deleteLocalAndGlobalRecord(
                                  snapshot.data![index]['id']);
                            }
                          },
                          key: ValueKey(snapshot.data![index]['id']),
                          direction: DismissDirection.horizontal,
                          background: Container(
                            decoration: const BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: Colors.red,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(3))),
                          ),
                          child: SizedBox(
                            height: 150,
                            child: Card(
                                elevation: 3,
                                child: Center(
                                    child: Text(
                                        snapshot.data![index]['content']))),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
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
                    const ElevatedButton(
                        style: ButtonStyle(
                            elevation: WidgetStatePropertyAll(3),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(3)),
                              ),
                            )),
                        onPressed: null,
                        child: Text('Домой')),
                    ElevatedButton(
                        style: const ButtonStyle(
                            elevation: WidgetStatePropertyAll(3),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(3)),
                              ),
                            )),
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
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(3)),
                                    ),
                                  )),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(3))),
                                      content: FutureBuilder(
                                        future: getJsonData(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircularProgressIndicator();
                                          } else if (snapshot.hasError) {
                                            return const Text(
                                                'Нет новых цитат');
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(jsonDecode(
                                                snapshot.data!)['content']),
                                          );
                                        },
                                      ),
                                      elevation: 3,
                                    );
                                  },
                                );
                              },
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
                                  elevation: WidgetStatePropertyAll(3),
                                  shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(3))))),
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
                        style: const ButtonStyle(
                            elevation: WidgetStatePropertyAll(3),
                            shape:
                                WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3)),
                            ))),
                        onPressed: () {
                          context.go('/');
                        },
                        child: const Text('Домой')),
                    const ElevatedButton(
                        style: ButtonStyle(
                            elevation: WidgetStatePropertyAll(3),
                            shape:
                                WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3)),
                            ))),
                        onPressed: null,
                        child: Text('О нас'))
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
                margin: const EdgeInsets.all(15), child: const MapScreen()),
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

Future<String> getJsonData() async {
  Response response = await get(Uri.http('127.0.0.1:8000', '/api/prophecy'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic YWRtaW46YWRtaW4='
      });
  String data = utf8.decode(response.bodyBytes);
  int id = jsonDecode(data)['id'];
  await addData(id, jsonDecode(data));
  return data;
}

Future<void> deleteLocalAndGlobalRecord(int id) async {
  final dbFactory = getIdbFactory();
  final db = await dbFactory?.open('my_database');
  final txn = db?.transaction('my_store', 'readwrite');
  final store = txn?.objectStore('my_store');

  await store?.delete(id);
  await txn?.completed;

  await delete(
    Uri.http('127.0.0.1:8000', '/api/prophecy/$id'),
    headers: {'Authorization': 'Basic YWRtaW46YWRtaW4='},
  );
}

Future<void> deleteLocalRecord(int id) async {
  final dbFactory = getIdbFactory();
  final db = await dbFactory?.open('my_database');
  final txn = db?.transaction('my_store', 'readwrite');
  final store = txn?.objectStore('my_store');

  await store?.delete(id);
  await txn?.completed;

  await patch(
    Uri.http('127.0.0.1:8000', '/api/prophecy/$id'),
    headers: {'Authorization': 'Basic YWRtaW46YWRtaW4='},
  );
}

Future<void> initializeDatabase() async {
  // Название базы данных
  const dbName = 'my_database';

  // Версия базы данных
  const dbVersion = 1;

  // Открываем или создаем базу данных
  final dbFactory = getIdbFactory(); // Получаем фабрику для IndexedDB
  await dbFactory?.open(dbName, version: dbVersion,
      onUpgradeNeeded: (VersionChangeEvent event) {
    // Создаем хранилище, если база данных обновляется
    final db = event.database;
    if (!db.objectStoreNames.contains('my_store')) {
      db.createObjectStore('my_store');
    }
  });
}

Future<void> addData(int id, Map<String, dynamic> value) async {
  final dbFactory = getIdbFactory();
  final db = await dbFactory?.open('my_database');
  final txn = db?.transaction('my_store', 'readwrite');
  final store = txn?.objectStore('my_store');

  await store?.put(value, id);
  await txn?.completed;
}

Future<List<Map<String, dynamic>>> getAllRecords() async {
  final dbFactory = getIdbFactory();

  final db = await dbFactory!.open('my_database');

  final txn = db.transaction('my_store', 'readonly');
  final store = txn.objectStore('my_store');

  final records = await store.getAll();

  await txn.completed;

  return records.map((e) => e as Map<String, dynamic>).toList();
}

Future<void> deleteDatabase() async {
  final dbFactory = getIdbFactory();
  await dbFactory?.deleteDatabase('my_database');
}
