import 'package:cvicebnice/tasksregister.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share/share.dart';

//import 'package:flutter_linkify/flutter_linkify.dart';

import './screens/level_select.dart';

//import '/widgets/launchurl.dart';
//import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // dev banner on/off
      title: 'EduKids.cz: Matika do kapsy',
      theme: ThemeData(
        textTheme: GoogleFonts.mcLarenTextTheme(),
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xffa02b5f),
          textTheme: ButtonTextTheme.primary,
          colorScheme:
              Theme.of(context).colorScheme.copyWith(secondary: Colors.white),
        ),
        appBarTheme: AppBarTheme(
            textTheme: GoogleFonts.mcLarenTextTheme(
              Theme.of(context)
                  .textTheme
                  .apply(bodyColor: Colors.white, displayColor: Colors.white),
            ),
            color: Color(0xff2b9aa0)),
//        primarySwatch: Color.fromRGBO(160, 43, 95, 1),
      ),
      home: TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  /// Togglebuttons current selection - tasks list
  int taskSelectedIndex;

  /// Currently selected level index
  int levelSelectedIndex;

  /// Currently selected xid of the particular task level
  String levelXid;

  bool descriptionPaneVisible = false;

  final GlobalKey<ScaffoldState> globalTaskListScaffoldKey =
      GlobalKey<ScaffoldState>();

  // we use [tasksRegister] List here - imported from tasksregister.dart

  @override
  void initState() {
    // set the togglebuttons for task selection
    taskSelectedIndex = 0;
    levelSelectedIndex = 0;
    levelXid = "???-???";

    super.initState();
  }

  /// Navigating to the TaskScreen
  void playWithSelectedLevelIndex() {
    print("Selected level to play: $levelSelectedIndex");
    // if level not yet implemented, just Toast
    if (!tasksRegister[taskSelectedIndex]
        .isLevelImplemented(levelSelectedIndex)) {
      print(
          "Cannot practise: $levelSelectedIndex for ${tasksRegister[taskSelectedIndex].label}");
    } else {
      Navigator.push(
        context,
        // Open task screen
        MaterialPageRoute(builder: (context) {
          return tasksRegister[taskSelectedIndex]
              .onOpenTaskScreen(levelSelectedIndex);
        }),
      );
    }
  }

  /// Requests task register whether level exists for the particular task environment
  bool checkLevelExists(int index) =>
      tasksRegister[taskSelectedIndex].isLevelImplemented(index);

  @override
  Widget build(BuildContext context) {
    bool canPlayLevel = checkLevelExists(levelSelectedIndex);

    return Scaffold(
      key: globalTaskListScaffoldKey,
      extendBody: true,
//      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.chalkboardTeacher),
            onPressed: () {
              setState(() {
                descriptionPaneVisible = !descriptionPaneVisible;
              });
            },
          ),
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("EduKids.cz / Matika do kapsy"),
//            Text("(prototyp)"),
//            Linkify(text: "www.edukids.cz"),
//            GestureDetector(
//                behavior: HitTestBehavior.translucent,
//                onTap: () async {
//                  await launchURL("https://www.edukids.cz");
//                },
//                child: Text(
//                  "EduKids",
//                  style: TextStyle(color: Color(0xffeeeeee)),
//                )),
          ],
        ),
//        shape: ShapeBorder(),

//        bottom: PreferredSize(
//          preferredSize: Size.fromHeight(56),
//          child: AppTaskBar(taskSelectedIndex: taskSelectedIndex),
//        ),
      ),
      body: SafeArea(
        child: Container(
//          color: Colors.pink,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text("Prostředí úloh",
                      style: Theme.of(context).textTheme.headline6),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ToggleButtons(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    children: List.generate(
                      tasksRegister.length,
                      (index) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Image.asset(
                            tasksRegister[index].imageAssetName,
                            width: 128,
                          ),
                          Text(tasksRegister[index].label),
                          Container(height: 8),
                        ],
                      ),
                    ),
                    onPressed: (int index) {
                      setState(() {
                        taskSelectedIndex = index;
                      });
                    },
                    isSelected: List.generate(
                        tasksRegister.length, (i) => (i == taskSelectedIndex)),
                  ),
                ),
                LevelSelect(
                  onCheckLevelExists: (index) => checkLevelExists(index),

//                      tasksRegister[taskSelectedIndex]
//                          .isLevelImplemented(index),
                  onSchoolClassToLevelIndex: (schoolYear, schoolMonth) =>
                      tasksRegister[taskSelectedIndex]
                          .onSchoolClassToLevelIndex(
                              schoolYear.toInt(), schoolMonth.toInt()),
                  onPlay: (int selectedLevelIndex) {
                    print("Selected level to play: $selectedLevelIndex");
                    // if level not yet implemented, just Toast
                    if (!tasksRegister[taskSelectedIndex]
                        .isLevelImplemented(selectedLevelIndex)) {
// must use builder function
//                Scaffold.of(context).showSnackBar(SnackBar(
//                  content: Text(
//                      "Úroveň $selectedLevelIndex není ještě naimplemetovaná."),
//                ));

                    } else {
                      Navigator.push(
                        context,
                        // Open task screen
                        MaterialPageRoute(builder: (context) {
                          return tasksRegister[taskSelectedIndex]
                              .onOpenTaskScreen(selectedLevelIndex);
                        }
//
                            ),
                      );
                    }

                    //////////////////////////
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: canPlayLevel ? Color(0xffa02b5f) : Colors.grey,
        mini: !canPlayLevel,
        tooltip: "Procvičit",
        elevation: 4,
        child: canPlayLevel ? FaIcon(FontAwesomeIcons.play) : Icon(Icons.block),
        onPressed: canPlayLevel
            ? () {
                playWithSelectedLevelIndex();
              }
            : null,
      ),
      bottomNavigationBar: BottomAppBar(
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          height: descriptionPaneVisible ? 256 : 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LevelNumberSelector(
                      levelIndex: levelSelectedIndex,
                      onIndexChange: (newLevelIndex) {
                        setState(() {
                          levelSelectedIndex = newLevelIndex;
                        });
                      },
                    ),
                    Container(
//                  width: 80,
//                  color: Colors.deepOrange,
                      child: Row(
                        children: [
                          LevelXidSelector(
                            levelXid: levelXid,
                            onSubmittedXid: (newXid) {
                              print("Mam $newXid");
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.share, color: Colors.white),
                            onPressed: () {
                              Share.share(
                                  "Matika do kapsy: ${tasksRegister[taskSelectedIndex].label} -> "
                                  "Kód úlohy: aeb-3ip ( http://matikadokapsy.edukids.cz/ )",
                                  subject: "#edukids úloha z matematiky");
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
//                        color: Colors.deepOrange,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(),
                            Text(
                                "Prostředí: ${tasksRegister[taskSelectedIndex].label}, "
                                "úrovně $levelSelectedIndex",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                            canPlayLevel
                                ? Text(
                                    "Vhodné pro xxxx. třídu (květen) a pro yyy. třídu (září).",
                                    style: TextStyle(color: Colors.white))
                                : Container(),
                            Divider(),
                            !canPlayLevel
                                ? Text(
                                    "Ještě není připraveno :( \n\n"
                                    "Můžete nám pomoci - na www.edukids.cz\n",
                                    style: TextStyle(color: Colors.white))
                                : Container(),
                            Text(
                                tasksRegister[taskSelectedIndex]
                                    .getLevelDescription(levelSelectedIndex),
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
//          color: Colors.deepOrange,
        ),
        shape: CircularNotchedRectangle(),
        color: Color(0xff2b9aa0),
      ),
    );
  }
}
