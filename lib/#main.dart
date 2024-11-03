import 'dart:convert';
import 'dart:io' as io;
import 'dart:developer' as d;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_driver/driver_extension.dart';

import 'go_main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Animate.restartOnHotReload = true;
  runApp(MaterialApp.router(
    routerConfig: router,
    theme: ThemeData(
      scaffoldBackgroundColor: Colors.white,
    ),
    debugShowCheckedModeBanner: false,
  ));
}

class FirstScreen extends StatefulWidget {
  const FirstScreen({
    super.key,
  });

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen>
    with SingleTickerProviderStateMixin {
  late String variableFromSecondScreen;
  late AnimationController controller;
  bool isClicked = false;
  var counter = 0.0;
  Color color = Colors.red;
  late Animation<double> tween;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )
      ..forward();
    tween = Tween(begin: 0.0, end: 50.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.bounceInOut));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    variableFromSecondScreen =
        GoRouterState
            .of(context)
            .extra
            ?.toString() ?? '';

    return SafeArea(
      top: true,
      child: Scaffold(
        drawer: Drawer(
          child: Column(
            children: [
              const Text('Drawer'),
              Semantics(
                hint: 'Button to the second screen',
                label: 'Tap your ass',
                enabled: true,
                onTap: () {
                  context.go('/second');
                },
                child: TextButton(
                    onPressed: () {
                      context.go('/second');
                    },
                    child: const Text('Press me')),
              )
            ],
          ),
        ),
        appBar: AppBar(
          elevation: 20,
          leading: IconButton(
            icon: const Icon(Icons.login),
            onPressed: () {
              context.go('/login');
            },
          ),
          leadingWidth: 100,
        ),
        body: Center(
          child: Column(
            children: [
              const Spacer(),
              RepaintBoundary(
                child: Stack(
                  children: [
                    Container(
                        width: 200,
                        height: 200,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                        ),
                        child: Center(child: Text(variableFromSecondScreen))),
                    AnimatedBuilder(
                      animation: controller,
                      builder: (context, child) {
                        return Positioned(
                            left: 50, top: tween.value, child: child!);
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              InputChip(
                onPressed: () {
                  showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (context) =>
                    const AlertDialog(
                      title: Text('Dialog'),
                      content: Text('This is a dialog'),
                    ),
                  );
                  controller.stop();
                },
                pressElevation: 30,
                elevation: 20,
                shape: const ContinuousRectangleBorder(),
                avatar: CircleAvatar(
                  backgroundColor: Colors.grey.shade800,
                  child: const Text('AB'),
                ),
                label: const Text('Aaron Burr'),
              ),
              const Spacer(),
              Builder(
                builder: (context) =>
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RepaintBoundary(
                          child: Slider(
                            value: counter,
                            onChanged: (value) {
                              setState(() {
                                counter = value;
                                color =
                                Color.lerp(Colors.red, Colors.blue, counter)!;
                              });
                            },
                          ),
                        ),
                        RepaintBoundary(
                          child: TweenAnimationBuilder(
                              tween: ColorTween(begin: Colors.red, end: color),
                              duration: const Duration(milliseconds: 3000),
                              builder: (context, value, child) =>
                                  TextButton(
                                    onPressed: () {
                                      d.log(
                                        'pressed button on first screen',
                                        name: 'first',
                                        time: DateTime.now(),
                                        error: {'status': 'bad'},
                                      );
                                      context.go('/second');
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                      WidgetStateProperty.all(color),
                                    ),
                                    child: const Text(
                                      'вперед',
                                    ),
                                  )),
                        ),
                      ],
                    ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  const SecondScreen({
    super.key,
  });

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  final _controller = TextEditingController();
  int counter = 0;
  bool isShaped = false;

  double x = 0;
  double y = 0;

  void onTap(int value) {
    setState(() {
      counter = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              flexibleSpace: const TabBar(
                tabs: [
                  Tab(text: 'first'),
                  Tab(text: 'second'),
                  Tab(text: 'third'),
                  Tab(text: 'fourth'),
                ],
              ),
            ),
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Row(
                  children: [
                    NavigationRail(
                      minWidth: 10,
                      elevation: 20,
                      selectedIndex: counter,
                      onDestinationSelected: onTap,
                      labelType: NavigationRailLabelType.selected,
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.favorite_border),
                          label: Text('first'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.bookmark_border),
                          label: Text('second'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.star_border),
                          label: Text('third'),
                        ),
                      ],
                    ),
                    const Expanded(
                      child: Center(
                        child: Text('first'),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            x += details.delta.dx;
                            y += details.delta.dy;
                          });
                        },
                        onTap: () {
                          setState(() {
                            isShaped = !isShaped;
                          });
                        },
                        child: Transform.translate(
                          offset: Offset(x, y),
                          child: AnimatedContainer(
                              duration: const Duration(milliseconds: 2000),
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                  color: isShaped ? Colors.blue : Colors.red)),
                        ),
                      ),
                      TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          label: Text('введите имя'),
                        ),
                      ),
                      const Spacer(),
                      FutureBuilder(
                        future: pos(),
                        builder: (context, snapshot) =>
                            Text(snapshot.data.toString()),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          context.go('/');
                        },
                        child: const Text('Close'),
                      )
                    ],
                  ),
                ),
                Center(
                  child: ElevatedButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('login')),
                ),
                const Center(
                  child: Text('third'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ThirdScreen extends StatefulWidget {
  const ThirdScreen({super.key});

  @override
  State<ThirdScreen> createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  late FocusNode focusNode;
    
  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  void _moveFocus(BuildContext context, FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.go('/');
            },
          ),
        ),
        body: Center(
          child: SizedBox(
            width: 300,
            child: Column(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Center(
                      child: Column(
                        children: [
                          TextField(
                            decoration: const InputDecoration(
                                label: Text('введите имя')),
                            onTapOutside: (event) =>
                                _moveFocus(context, focusNode),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextField(
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                                label: Text('введите емейл')),
                            style:
                            const TextStyle(color: Colors.black, height: 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                Container(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          offset: Offset(5, 5),
                          color: Color.fromRGBO(0, 0, 0, 0.5),
                          blurRadius: 5,
                        )
                      ]),
                  child: SegmentedButton(
                    style: ButtonStyle(
                        side: WidgetStateBorderSide.resolveWith(
                              (states) {
                            return const BorderSide(style: BorderStyle.none);
                          },
                        ),
                        backgroundColor:
                        const WidgetStatePropertyAll(Colors.orange)),
                    emptySelectionAllowed: true,
                    segments: const <ButtonSegment<Colorize>>[
                      ButtonSegment<Colorize>(
                        label: Text('blue'),
                        value: Colorize.blue,
                      ),
                      ButtonSegment(
                        label: Text('red'),
                        value: Colorize.red,
                      ),
                      ButtonSegment(
                        label: Text('green'),
                        value: Colorize.green,
                      ),
                      ButtonSegment(
                        label: Text('yellow'),
                        value: Colorize.yellow,
                      ),
                    ],
                    selected: const <Colorize>{Colorize.blue},
                    onSelectionChanged: (p0) {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2025),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  String _name = 'max';

  String get name => _name;

  void changeName(String newName) {
    _name = newName;
    notifyListeners();
  }
}

Future<http.Response> fetch() async {
  return await http.get(
    Uri.parse('https://jsonplaceholder.typicode.com/todos/1'),
  );
}

Future<http.Response> get() async {
  return await http.get(
    Uri.parse('https://jsonplaceholder.typicode.com/todos/2'),
  );
}

Future<String> pos() async {
  Uri url = Uri.parse('https://jsonplaceholder.typicode.com/posts');
  http.Response response = await http
      .post(url, body: {'title': 'foo', 'body': 'bar', 'userId': '1'});
  return response.body;
}

enum Colorize { red, green, blue, yellow }
