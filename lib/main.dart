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
  await initializeDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFE0E0E0),
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStatePropertyAll(Colors.blue),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          textStyle: TextStyle(
            foreground: Paint()..color = Colors.black,
          ),
          iconColor: Colors.black,
          disabledBackgroundColor: Colors.grey,
        )),
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int count = 0;
  List<Map<String, dynamic>> records = [];
  bool backendStatus = false;
  int charCount = 0;

  Future<void> getStatus() async {
    backendStatus = await getBackendStatus();
    setState(() {});
  }

  setCount() async {
    count = (await getAllRecords()).length;
    setState(() {});
  }

  loadRecords() async {
    records = (await getAllRecords()).reversed.toList();
    await setRecordsFromDB(records);
    setState(() {});
  }

  @override
  initState() {
    super.initState();
    // getStatus().then((_) {
    //   if (backendStatus) {
    //     setCount();
    //     loadRecords();
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 750) {
        return Scaffold(
          body: Row(
            children: [
              Expanded(
                child: TextArea(),
              ),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 70,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 30.0, left: 5),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.keyboard_double_arrow_left),
                                  Padding(
                                    padding: EdgeInsets.only(left: 5, right: 5),
                                    child: SizedBox(
                                      width: constraints.maxWidth * 0.16,
                                      child: Text(
                                        'Смахнуть для удаления локально',
                                        style: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text('$count',
                                style: const TextStyle(
                                  fontSize: 10,
                                )),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 5, right: 5),
                                  child: SizedBox(
                                    width: constraints.maxWidth * 0.16,
                                    child: Text(
                                      textAlign: TextAlign.right,
                                      'Смахнуть для удаления глобально',
                                      style: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 10),
                                    ),
                                  ),
                                ),
                                Icon(Icons.keyboard_double_arrow_right),
                              ],
                            ),
                          ]),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: records.isNotEmpty
                              ? Builder(builder: (context) {
                                  ScrollController scrollController =
                                      ScrollController();
                                  return Scrollbar(
                                    controller: scrollController,
                                    thumbVisibility: true,
                                    interactive: true,
                                    child: ListView.builder(
                                      controller: scrollController,
                                      itemCount: records.length,
                                      itemBuilder: (context, index) {
                                        TextEditingController controller =
                                            TextEditingController(
                                                text: records[index]
                                                    ['content']);
                                        return GestureDetector(
                                          onDoubleTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                actions: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Количество символов X: 15 < X < 1500',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color:
                                                              Color(0xFFFF0000),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        style: ButtonStyle(
                                                            backgroundColor:
                                                                WidgetStatePropertyAll(
                                                                    Color(
                                                                        0xFFFF722F)),
                                                            elevation:
                                                                WidgetStatePropertyAll(
                                                                    3),
                                                            shape:
                                                                WidgetStatePropertyAll(
                                                              RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            3)),
                                                              ),
                                                            )),
                                                        onPressed: () {
                                                          if (controller
                                                                      .text !=
                                                                  '' &&
                                                              controller.text
                                                                      .length >
                                                                  15 &&
                                                              controller.text
                                                                      .length <
                                                                  1500) {
                                                            putContent(
                                                                records[index]
                                                                    ['id'],
                                                                controller
                                                                    .text);
                                                            if (context
                                                                .mounted) {
                                                              Navigator.pop(
                                                                  context);
                                                            }
                                                          }
                                                        },
                                                        child: Text('ok'),
                                                      )
                                                    ],
                                                  )
                                                ],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(3)),
                                                ),
                                                contentPadding: EdgeInsets.zero,
                                                content: SizedBox(
                                                  height: 400,
                                                  width: 600,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: TextField(
                                                      decoration:
                                                          InputDecoration(
                                                              border:
                                                                  OutlineInputBorder(
                                                        borderSide:
                                                            BorderSide.none,
                                                      )),
                                                      controller: controller,
                                                      maxLines: 40,
                                                      autofocus: true,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Dismissible(
                                            onDismissed: (direction) {
                                              if (direction ==
                                                  DismissDirection.endToStart) {
                                                deleteLocalRecord(
                                                    records[index]['id']);
                                                setState(() {
                                                  count--;
                                                });
                                              } else if (direction ==
                                                  DismissDirection.startToEnd) {
                                                deleteLocalAndGlobalRecord(
                                                    records[index]['id']);
                                                setState(() {
                                                  count--;
                                                });
                                              }
                                              setState(() {
                                                records.removeAt(index);
                                              });
                                            },
                                            key: ValueKey(records[index]['id']),
                                            direction:
                                                DismissDirection.horizontal,
                                            background: Container(
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(3))),
                                            ),
                                            child: SizedBox(
                                                height: 200,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 15.0),
                                                  child: Card(
                                                      color: Colors.white,
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 5,
                                                              right: 10,
                                                              bottom: 5,
                                                              top: 2),
                                                      elevation: 5,
                                                      child: records[index][
                                                                      'content']
                                                                  .length >
                                                              250
                                                          ? Builder(builder:
                                                              (context) {
                                                              ScrollController
                                                                  scrollController2 =
                                                                  ScrollController();
                                                              return Scrollbar(
                                                                controller:
                                                                    scrollController2,
                                                                interactive:
                                                                    true,
                                                                thumbVisibility:
                                                                    true,
                                                                child: ListView(
                                                                  controller:
                                                                      scrollController2,
                                                                  children: [
                                                                    Center(
                                                                        child:
                                                                            Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          10.0),
                                                                      child: Text(
                                                                          records[index]
                                                                              [
                                                                              'content']),
                                                                    ))
                                                                  ],
                                                                ),
                                                              );
                                                            })
                                                          : Center(
                                                              child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      10.0),
                                                              child: Text(records[
                                                                      index]
                                                                  ['content']),
                                                            ))),
                                                )),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                })
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Text(
                                        'Нет записей',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                    )
                                  ],
                                )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Двойной клик, что отредактировать карточку',
                            style: TextStyle(fontSize: 10),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 90,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: SizedBox(
                            height: 30,
                            child: ElevatedButton(
                              style: const ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(Color(0xFF9F93BF)),
                                  elevation: WidgetStatePropertyAll(3),
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(3)),
                                    ),
                                  )),
                              child: const ImageIcon(
                                  AssetImage('assets/icons/reload.png'),
                                  size: 18),
                              onPressed: () {
                                getStatus().then(
                                  (_) async {
                                    if (backendStatus) {
                                      count = (await getAllRecords()).length;
                                      records = (await getAllRecords())
                                          .reversed
                                          .toList();
                                      setState(() {
                                        count;
                                        records;
                                      });
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Нет соединения с базой данных'),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
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
          children: [
            TextArea(),
            ListOfCitates(),
          ],
        );
      }
    });
  }
}

class ListOfCitates extends StatefulWidget {
  const ListOfCitates({
    super.key,
  });

  @override
  State<ListOfCitates> createState() => _ListOfCitatesState();
}

class _ListOfCitatesState extends State<ListOfCitates> {
  int count = 0;
  List<Map<String, dynamic>> records = [];
  bool backendStatus = false;

  Future<void> getStatus() async {
    backendStatus = await getBackendStatus();
    setState(() {});
  }

  setCount() async {
    count = (await getAllRecords()).length;
    setState(() {});
  }

  loadRecords() async {
    records = (await getAllRecords()).reversed.toList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadRecords();
    setCount();
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20.0, right: 25, top: 5),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.keyboard_double_arrow_left),
                      Text(
                        'Смахнуть для удаления локально',
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  Text('$count',
                      style: const TextStyle(
                        fontSize: 10,
                      )),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Смахнуть для удаления глобально',
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      Icon(Icons.keyboard_double_arrow_right),
                    ],
                  ),
                ]),
          ),
          SizedBox(
            height: 3,
          ),
          Expanded(
            flex: 5,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: records.isNotEmpty
                    ? Builder(builder: (context) {
                        ScrollController scrollController = ScrollController();
                        return Scrollbar(
                          controller: scrollController,
                          thumbVisibility: true,
                          interactive: true,
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: records.length,
                            itemBuilder: (context, index) {
                              TextEditingController controller =
                                  TextEditingController(
                                      text: records[index]['content']);
                              return GestureDetector(
                                onDoubleTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      actions: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Количество символов X: 15 < X < 1500',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFFFF0000),
                                              ),
                                            ),
                                            ElevatedButton(
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      WidgetStatePropertyAll(
                                                          Color(0xFFFF722F)),
                                                  elevation:
                                                      WidgetStatePropertyAll(3),
                                                  shape: WidgetStatePropertyAll(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  3)),
                                                    ),
                                                  )),
                                              onPressed: () {
                                                if (controller.text != '' &&
                                                    controller.text.length >
                                                        15 &&
                                                    controller.text.length <
                                                        1500) {
                                                  putContent(
                                                      records[index]['id'],
                                                      controller.text);
                                                  if (context.mounted) {
                                                    Navigator.pop(context);
                                                  }
                                                }
                                              },
                                              child: Text('ok'),
                                            )
                                          ],
                                        )
                                      ],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                      content: SizedBox(
                                        height: 300,
                                        width: 600,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: TextField(
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                3)))),
                                            controller: controller,
                                            maxLines: 30,
                                            autofocus: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Dismissible(
                                  onDismissed: (direction) {
                                    if (direction ==
                                        DismissDirection.endToStart) {
                                      deleteLocalRecord(records[index]['id']);
                                      setState(() {
                                        count--;
                                      });
                                    } else if (direction ==
                                        DismissDirection.startToEnd) {
                                      deleteLocalAndGlobalRecord(
                                        records[index]['id'],
                                      );
                                      setState(() {
                                        count--;
                                      });
                                    }
                                    setState(() {
                                      records.removeAt(index);
                                    });
                                  },
                                  key: ValueKey(records[index]['id']),
                                  direction: DismissDirection.horizontal,
                                  background: Container(
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(3))),
                                  ),
                                  child: SizedBox(
                                      height: 200,
                                      child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 2,
                                              bottom: 4,
                                              right: 15,
                                              left: 15),
                                          child: Card(
                                              color: Colors.white,
                                              margin: const EdgeInsets.only(
                                                  left: 5,
                                                  right: 10,
                                                  bottom: 5,
                                                  top: 5),
                                              elevation: 5,
                                              child: records[index]['content']
                                                          .length >
                                                      250
                                                  ? Builder(builder: (context) {
                                                      ScrollController
                                                          scrollController2 =
                                                          ScrollController();
                                                      return Scrollbar(
                                                        controller:
                                                            scrollController2,
                                                        interactive: true,
                                                        thumbVisibility: true,
                                                        child: ListView(
                                                          controller:
                                                              scrollController2,
                                                          children: [
                                                            Center(
                                                                child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      10.0),
                                                              child: Text(records[
                                                                      index]
                                                                  ['content']),
                                                            ))
                                                          ],
                                                        ),
                                                      );
                                                    })
                                                  : Center(
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10.0),
                                                          child: Text(records[
                                                                  index]
                                                              ['content'])))))),
                                ),
                              );
                            },
                          ),
                        );
                      })
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  'Нет записей',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                )),
                          )
                        ],
                      )),
          ),
          SizedBox(
            height: 2,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Двойной клик, чтобы отредактировать карточку',
                  style: TextStyle(
                    fontSize: 10,
                  ))
            ]),
          )
        ],
      ),
    );
  }
}

class TextArea extends StatefulWidget {
  const TextArea({super.key});

  @override
  State<TextArea> createState() => _TextAreaState();
}

class _TextAreaState extends State<TextArea> {
  late TextEditingController controller;
  bool backendStatus = false;

  Future<void> getStatus() async {
    backendStatus = await getBackendStatus();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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
                        style: ButtonStyle(
                          elevation: WidgetStatePropertyAll(3),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3)),
                            ),
                          ),
                          backgroundColor:
                              WidgetStatePropertyAll(Color(0xFFFEF67F)),
                        ),
                        onPressed: () {
                          context.go('/about');
                        },
                        child: const Text('О нас')),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: TextField(
                controller: controller,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(2))),
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: TextStyle(color: Colors.grey),
                  hintText: 'Введите цитату и пошлите, куда следует',
                  helper: Text(
                    'Количество символов X: 15 < X < 1500',
                    style: TextStyle(fontSize: 10, color: Colors.red),
                  ),
                  contentPadding: EdgeInsets.all(15),
                ),
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
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(Color(0xFF72BB53)),
                                  elevation: WidgetStatePropertyAll(3),
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(3)),
                                    ),
                                  )),
                              onPressed: () {
                                getStatus().then(
                                  (_) {
                                    if (backendStatus) {
                                      if (context.mounted) {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  3))),
                                              content: FutureBuilder(
                                                future: getJsonData(),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return SizedBox(
                                                        height: 30,
                                                        child: Center(
                                                            child:
                                                                const CircularProgressIndicator()));
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return SizedBox(
                                                      height: 30,
                                                      child: Center(
                                                        child: const Text(
                                                            'Нет новых цитат'),
                                                      ),
                                                    );
                                                  }
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(jsonDecode(
                                                        snapshot
                                                            .data!)['content']),
                                                  );
                                                },
                                              ),
                                              elevation: 3,
                                            );
                                          },
                                        );
                                      }
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Нет соединения с базой данных'),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                );
                              },
                              child: const Text('Получить')),
                        ),
                      ),
                      if (MediaQuery.of(context).size.width < 700)
                        const Icon(Icons.keyboard_arrow_down_rounded),
                      SizedBox(
                        width: 150,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: ElevatedButton(
                              style: const ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(Color(0xFFF06E9C)),
                                  elevation: WidgetStatePropertyAll(3),
                                  shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(3))))),
                              onPressed: () {
                                getStatus().then(
                                  (_) {
                                    if (backendStatus) {
                                      if (controller.text != '' &&
                                          controller.text.length > 15 &&
                                          controller.text.length < 1500) {
                                        if (context.mounted) {
                                          showDialog<void>(
                                            context: context,
                                            builder:
                                                (BuildContext dialogContext) {
                                              return AlertDialog(
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    3))),
                                                content: FutureBuilder(
                                                  future: postData(controller),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) {
                                                      String data = utf8.decode(
                                                          snapshot
                                                              .data!.bodyBytes);
                                                      Map<String, dynamic>
                                                          answer =
                                                          jsonDecode(data);
                                                      WidgetsBinding.instance
                                                          .addPostFrameCallback(
                                                              (_) {
                                                        controller.clear();
                                                      });
                                                      return Text(
                                                          '${answer["message"]}');
                                                    }
                                                    return SizedBox(
                                                        height: 30,
                                                        child: Center(
                                                            child:
                                                                const CircularProgressIndicator()));
                                                  },
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      }
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Нет соединения с базой данных'),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                );
                              },
                              child: const Text('Отослать')),
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
                            backgroundColor:
                                WidgetStatePropertyAll(Color(0xFFFEF67F)),
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
  Response response = await get(Uri.https('backend-fi2g.onrender.com', '/api/prophecy'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic YWRtaW46YWRtaW4='
      });
  String data = utf8.decode(response.bodyBytes);
  int id = jsonDecode(data)['id'];
  await addData(id, jsonDecode(data));
  return data;
}

Future<Response> postData(TextEditingController controller) async {
  Response response = await post(Uri.https('backend-fi2g.onrender.com', '/api/prophecy'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic YWRtaW46YWRtaW4='
      },
      body: jsonEncode({"content": controller.text}));
  return response;
}

Future<void> deleteLocalAndGlobalRecord(int id) async {
  final dbFactory = getIdbFactory();
  final db = await dbFactory?.open('my_database');
  final txn = db?.transaction('my_store', 'readwrite');
  final store = txn?.objectStore('my_store');

  await store?.delete(id);
  await txn?.completed;

  await delete(
    Uri.https('backend-fi2g.onrender.com', '/api/prophecy/$id'),
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
    Uri.https('backend-fi2g.onrender.com', '/api/prophecy/$id'),
    headers: {'Authorization': 'Basic YWRtaW46YWRtaW4='},
  );
}

Future<void> putContent(int id, String content) async {
  final dbFactory = getIdbFactory();
  final db = await dbFactory?.open('my_database');
  final txn = db?.transaction('my_store', 'readwrite');
  final store = txn?.objectStore('my_store');

  await store?.put({"id": id, "content": content}, id);
  await txn?.completed;

  put(
    Uri.https('backend-fi2g.onrender.com', '/api/prophecy/$id'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Basic YWRtaW46YWRtaW4="
    },
    body: jsonEncode({"content": content}),
  );
}

Future<void> initializeDatabase() async {
  const dbName = 'my_database';

  const dbVersion = 1;

  final dbFactory = getIdbFactory();
  await dbFactory?.open(dbName, version: dbVersion,
      onUpgradeNeeded: (VersionChangeEvent event) {
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
  Response response = await get(Uri.https('backend-fi2g.onrender.com', '/api/prophecy/all'),
      headers: {'Authorization': 'Basic YWRtaW46YWRtaW4='});
  String data = utf8.decode(response.bodyBytes);
  List<dynamic> records = jsonDecode(data);
  return records.map((e) => e as Map<String, dynamic>).toList();
}

Future<void> setRecordsFromDB(List<Map<String, dynamic>> records) async {
  final dbFactory = getIdbFactory();
  final db = await dbFactory!.open('my_database');

  final txn = db.transaction('my_store', 'readwrite');
  final store = txn.objectStore('my_store');
  for (Map<String, dynamic> record in records) {
    await store.put(record, record['id']);
  }
  await txn.completed;
}

Future<bool> getBackendStatus() async {
  try {
    Response response = await get(Uri.https('backend-fi2g.onrender.com', '/api/health'),
        headers: {'Authorization': 'Basic YWRtaW46YWRtaW4='});
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}
