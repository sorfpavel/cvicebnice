import 'package:cvicebnice/screens/overlays/donesuccessoverlay.dart';
import 'package:cvicebnice/screens/overlays/donewrongoverlay.dart';
import 'package:cvicebnice/screens/overlays/optionsoverlay.dart';
import 'package:cvicebnice/widgets/small_numeric_keyboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'level.dart';
import 'leveltree.dart';
import 'submissioncontroller.dart';
import 'package:flutter/services.dart';

class TaskScreen extends StatefulWidget {
  final int selectedLevelIndex;

  TaskScreen({Key key, this.selectedLevelIndex}) : super(key: key);

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  bool _showBackground;
  bool taskSubmitted;
  bool optionsRequested;
  LevelTree levelTree;
  List<Level> questions;

  Level _level;

  /// Level index selected in the parent Widget
  int selectedLevelIndex;

  /// Amount of generated questions on the screen
  static const questionsAmount = 5;

  /// Controller for submission / solution checks
  SubmissionController submissionController;

  @override
  void initState() {
    selectedLevelIndex = widget.selectedLevelIndex;

//    selectedLevelIndex = 35; // for immediate debug only :)

    _showBackground ??= true;
    taskSubmitted ??= false;
    optionsRequested ??= false;

    questionsControllerInit();

    super.initState();
  }

  /// Initializes the questions for screen for the particular level index
  void questionsControllerInit() {
    levelTree = LevelTree();
    _level = levelTree.getLevelByIndex(selectedLevelIndex);
    questionsGenerate();

    submissionController = SubmissionController(screenQuestions: questions);
    submissionController.addListener(_checkSolution);

//    textControllers =
//        List.generate(questionsAmount, (_) => (TextEditingController()));

    taskSubmitted = false;
    optionsRequested = false;
  }

  /// Regenerates the questions for the screen
  void questionsRegenerate() {
//    submissionController.dispose(); // must not dispose here :(
    questionsControllerInit();
  }

  /// Generates the collection of questions
  ///
  /// tries x times to have unique questions
  void questionsGenerate() {
    questions = List.generate(questionsAmount, (_) => _level.clone());

    bool questionsHaveZero = false;
    for (int i = 0; i < questions.length; i++) {
      bool mustRegenerate;
      int tries = 5;
      do {
        questions[i].generate();
        tries--;
        /// avoid generating the same question / solution
        mustRegenerate = false;
        for (int j = 0; j < i; j++) {
          if (listEquals(questions[j].solution, questions[i].solution))
            mustRegenerate = true;
        }
        /// avoid more zeros among questions
        if (questionsHaveZero & questions[i].solution.contains(0)) mustRegenerate = true;
//        print("$i: $tries: ${questions[i].solution}");
      } while (mustRegenerate & (tries > 0));
      if (questions[i].solution.contains(0)) questionsHaveZero = true;
    }
  }

  _checkSolution() {
    print("Submission: ${submissionController.toString()} : "
        "solved: ${submissionController.isSolved}");
    setState(() {});
  }

  @override
  void dispose() {
    submissionController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TaskScreen oldWidget) {
    print('didUpdateWidget: $this');
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return CustomKeyboardCovered(
      child: Scaffold(
        body: SafeArea(
          child: Container(
            color: Color(0xffECE6E9),
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(0, 40, 0, 80),
                    child: QuestionList(
                      questions: questions,
                      textControllers: submissionController.cells,
//                      textControllers: textControllers,
                    ),
                  ),
                ),
                // top scrolling shade
                Container(
                  width: double.infinity,
                  height: 125,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xffECE6E9),
                        Color(0xccECE6E9),
                        Color(0x00ECE6E9),
                      ],
                      begin: FractionalOffset(0, 0),
                      end: FractionalOffset(0, 1),
                      stops: [0, 0.6, 1],
                      tileMode: TileMode.clamp,
                    ),
                  ),
                ),
                buildGuideAndButton(context),

                // Build overlays based on taskscreen states
                Builder(builder: (context) {
                  if (!taskSubmitted & optionsRequested)
                    return buildOptionsOverlay(context);
                  if (taskSubmitted) {
                    return submissionController.isSolved

                        /// task is submitted and solved successfully
                        ? DoneSuccessOverlay(
                            onNextUpLevel: () {
                              setState(() {
                                selectedLevelIndex =
                                    levelTree.getMoreDifficultLevelIndex(
                                        selectedLevelIndex);
                                questionsRegenerate();
                              });
                            },
                            onNextSameLevel: () {
                              setState(() {
                                questionsRegenerate();
                              });
                            },
                            onBack: () {
                              Navigator.of(context).pop();
                            },
                          )

                        /// task is submitted, but not solved
                        : DoneWrongOverlay(
                            onBackToLevel: () {
                              setState(() {
                                taskSubmitted = false;
                              });
                            },
                          );
                  }
                  // no options overlay to show
                  return Container();
                }),

                // Check the task is not submitted
//                (!taskSubmitted) ? buildOptionsOverlay(context) : Container(),
//                (taskSubmitted && submissionController.isSolved) ? build: Container();
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build overlay for Options
  ///
  /// Must be inside the TaskScreen class in order to handle options
  Widget buildOptionsOverlay(context) {
    /// No shade overlay requested
    if (!optionsRequested) return Container();

    /// Options menu requested
    return OptionsOverlay(
      canDecreaseLevel: (_level.index > 2),
      levelInfoText: _level.index.toString() + " ze 150",
      showBackground: _showBackground,
      onBackToLevel: () {
        setState(() {
          optionsRequested = false;
        });
      },
      onBack: () {
        Navigator.of(context).pop();
      },
      onRestartLevel: () {
        setState(() {
          submissionController.eraseSubmission();
          optionsRequested = false;
        });
      },
      onSwitchBackgroundImage: () {
        setState(() {
          _showBackground = !_showBackground;
          optionsRequested = false;
        });
      },
      onDecreaseLevel: () {
        setState(() {
          selectedLevelIndex =
              levelTree.getLessDifficultLevelIndex(selectedLevelIndex);
          questionsRegenerate();
          optionsRequested = false;
        });
      },
    );
  }

  /// Build Guide head and Action button
  ///
  /// Must be inside the TaskScreen class in order to handle options
  Positioned buildGuideAndButton(BuildContext context) {
    return Positioned(
      left: 20,
      top: 20,
      right: 20,
      child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                setState(() {
                  /// must hide keyboard before option overlay is shown
                  removeEditableFocus(context);
                  optionsRequested = true;
                });
              },
              child: Image.asset(
                "assets/ada_head_only.png",
                width: 100,
              ),
            ),
//                          Container(width: 20),

            submissionController.isFilled
//            true
                ? RaisedButton(
                    shape: StadiumBorder(),
                    child: Text("HOTOVO?"),
                    onPressed: () {
                      setState(() {
                        /// must hide keyboard before done overlay is shown
                        removeEditableFocus(context);
                        taskSubmitted = true;
                      });
                    },
                  )
                // ignore: dead_code
                : Container(),
          ]),
    );
  }
}

/// Render set of questions
class QuestionList extends StatelessWidget {
  final List<Level> questions;
  final List<TextEditingController> textControllers;

  const QuestionList({
    Key key,
    this.questions,
    this.textControllers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 130, 0, 0),
      child: Column(
        children: List.generate(
            questions.length,
            (index) => Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                  child: Question(
                    textController: textControllers[index],
                    mask: questions[index].selectedQuestionMask,
                    solution: questions[index].solution,
//                      solution: [4008, 3548, 7556]
                  ),
                )),
      ),
    );
  }
}

/// Render one question
class Question extends StatelessWidget {
  /// Form of the question
  ///
  /// "x+y=Z", "X+y=z", "x+Y=z", "x+y+w=Z", "100=k+X"
  final String mask;

  /// [k, x] or [x,y,z] or [x,y,w,z]
  final List<int> solution;

  /// Controller for the editinput
  final TextEditingController textController;

  static const double textSize = 32;

  const Question({
    Key key,
    this.mask,
    this.solution,
    this.textController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (mask == "x+y=Z") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          QText(solution[0].toString()),
          QText("+"),
          QText(solution[1].toString()),
          QText("="),
          QuestionInputField(
            textController: textController,
          ),
//          Text(
//            "????",
//            style: TextStyle(fontSize: textSize),
//          ),
        ],
      );
    }

    if (mask == "X+y=z") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          QuestionInputField(
            textController: textController,
          ),
          QText("+"),
          QText(solution[1].toString()),
          QText("="),
          QText(solution[2].toString()),
        ],
      );
    }

    if (mask == "x+Y=z") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          QText(solution[0].toString()),
          QText("+"),
          QuestionInputField(
            textController: textController,
          ),
          QText("="),
          QText(solution[2].toString()),
        ],
      );
    }

    if (mask == "x+y+w=ZZ") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          QText(solution[0].toString()),
          QText("+"),
          QText(solution[1].toString()),
          QText("+"),
          QText(solution[2].toString()),
          QText("="),
          QuestionInputField(
            textController: textController,
            length: 2,
          ),
        ],
      );
    }

    if (mask == "100=k+X") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          QText("100"),
          QText("="),
          QText(solution[0].toString()),
          QText("+"),
          QuestionInputField(
            textController: textController,
            length: 2,
          ),
        ],
      );
    }

    print("mask $mask not implemented");
    return Container();
  }
}

/// Text part to be rendered for the question
class QText extends StatelessWidget {
  const QText(
    this.text, {
    Key key,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 32),
    );
  }
}

/// Editing field
///
/// note keyboardType
class QuestionInputField extends StatelessWidget {
  final TextEditingController textController;

  /// Max length of the input value
  final int length;

  QuestionInputField({
    Key key,
    this.textController,
    this.length,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 50,
      decoration: BoxDecoration(
        color: Color(0x109C4D82),
      ),
      child: Center(
        child: TextField(
          /// enableInteractiveSelection must NOT be false, otherwise KeyboardController error
//                  enableInteractiveSelection: false,
          keyboardType: SmallNumericKeyboard.text,
//                  keyboardType: TextInputType.number,
          inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
          controller: textController,
          cursorColor: Color(0xffa02b5f),
          autocorrect: false,
          maxLength: length ?? 4,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 32,
          ),
//            readOnly: true,
//            showCursor: true,
          // hide length counter and underline
          decoration: null,
          buildCounter: (BuildContext context,
                  {int currentLength, int maxLength, bool isFocused}) =>
              null,
        ),
      ),
    );
  }
}
