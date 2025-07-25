import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'trainupperbody2_model.dart';
export 'trainupperbody2_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/main.dart';
import '../vision_detector_views/pose_transform.dart';
import '../vision_detector_views/pose_video.dart';
import '/flutter_flow/bottom_navigation.dart';

class Trainupperbody2Widget extends StatefulWidget {
  const Trainupperbody2Widget({Key? key}) : super(key: key);

  @override
  _Trainupperbody2WidgetState createState() => _Trainupperbody2WidgetState();
}

class _Trainupperbody2WidgetState extends State<Trainupperbody2Widget> {
  late Trainupperbody2Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();

  var gettime = DateTime.now(); //獲取按下去的時間
  var gettime1; //轉換輸出型態月日年轉年月日

  /*inputtime()async{                                                           //此函式是鎖一天只能做一個動作並傳遞後端
    var url = Uri.parse(ip+"inputtime.php");
    final responce = await http.post(url,body: {
      "account" : FFAppState().accountnumber,
      "degree":"進階",
      "parts":"上肢",
      "time": gettime1.toString(),
      "action": FFAppState().trainup,//動作
    });
    if (responce.statusCode == 200) {
      var data = json.decode(responce.body); //將json解碼為陣列形式
      print(data["action"]);
      print(data["time"]);
      //print(gettime1=dateTimeFormat('yyyy-M-d', gettime));//轉換輸出型態月日年轉年月日
      if("沒時間"==data["time"]){
        if("有訓練"==data["action"]||"有時間"==data["time"]){

        }
        else{
          Navigator.push(context,
            MaterialPageRoute(builder: (context)=>VideoApp()),
          );
        }
      }
      else if(data["times"]=="1次"&&"有時間"==data["time"]){
        if(data["timeaction"]=="對"){
          Navigator.push(context,
            MaterialPageRoute(builder: (context)=>VideoApp()),
          );
        }
      }
      else if(data["times"]=="2次"){

      }
    }
  }*/

  inputtime() async {
    // 此函式為代替方案，不限制一天動作，可以一職測試 測試完請刪掉
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VideoApp()),
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Trainupperbody2Model());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        FFAppState().trainup = '聳肩動作';
      });
    });
  }

  @override
  void dispose() {
    _model.dispose();

    _unfocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    gettime1 = dateTimeFormat('yyyy-M-d', gettime);
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFF90BDF9),
        body: SafeArea(
          top: true,
          bottom: false, // 關閉底部安全區域，讓導航欄可以貼合底部
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 固定標題區域
              Container(
                width: double.infinity,
                height: isLandscape
                    ? screenHeight * 0.15
                    : screenHeight * 0.1, // 根據方向設置不同的高度比例
                color: Color(0xFF90BDF9),
                padding: EdgeInsets.symmetric(
                    vertical: isLandscape
                        ? screenHeight * 0.01
                        : screenHeight * 0.01),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          screenWidth * 0.03, 0.0, 0.0, 0.0),
                      child: Image.asset(
                        'assets/images/13.png',
                        width: isLandscape
                            ? screenHeight * 0.1
                            : screenWidth * 0.15,
                        height: isLandscape
                            ? screenHeight * 0.1
                            : screenWidth * 0.15,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          screenWidth * 0.04, 0.0, 0.0, 0.0),
                      child: Text(
                        '進階訓練',
                        textAlign: TextAlign.start,
                        style:
                            FlutterFlowTheme.of(context).displaySmall.override(
                                  fontFamily: 'Poppins',
                                  fontSize: isLandscape
                                      ? screenHeight * 0.07 // 橫向時使用螢幕高度比例
                                      : screenWidth * 0.08, // 直向時使用螢幕寬度比例
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                  ],
                ),
              ),

              // 中間內容區域 (可滾動)
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    child: isLandscape
                        // 橫向模式
                        ? Padding(
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            child: Column(
                              children: [
                                // 第一排 (3個訓練)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildExerciseItem(
                                      context: context,
                                      imagePath: 'assets/images/28.png',
                                      title: '肩膀前舉',
                                      screenSize: screenSize,
                                      isLandscape: true,
                                      onTap: () async {
                                        if (FFAppState().affectedside == null)
                                          return;
                                        else if (FFAppState().affectedside ==
                                            "右側")
                                          global.posenumber = 6;
                                        else
                                          global.posenumber = 30;
                                        setState(() {
                                          FFAppState().trainup = '肩膀前舉';
                                        });
                                        inputtime();
                                      },
                                    ),
                                    _buildExerciseItem(
                                      context: context,
                                      imagePath: 'assets/images/29.png',
                                      title: '手肘前伸',
                                      screenSize: screenSize,
                                      isLandscape: true,
                                      onTap: () async {
                                        if (FFAppState().affectedside == null)
                                          return;
                                        else if (FFAppState().affectedside ==
                                            "右側")
                                          global.posenumber = 7;
                                        else
                                          global.posenumber = 31;
                                        setState(() {
                                          FFAppState().trainup = '手肘前伸';
                                        });
                                        inputtime();
                                      },
                                    ),
                                    _buildExerciseItem(
                                      context: context,
                                      imagePath: 'assets/images/30.png',
                                      title: '肩膀側舉',
                                      screenSize: screenSize,
                                      isLandscape: true,
                                      onTap: () async {
                                        if (FFAppState().affectedside == null)
                                          return;
                                        else if (FFAppState().affectedside ==
                                            "右側")
                                          global.posenumber = 8;
                                        else
                                          global.posenumber = 32;
                                        setState(() {
                                          FFAppState().trainup = '肩膀側舉';
                                        });
                                        inputtime();
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                // 第二排 (3個訓練)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildExerciseItem(
                                      context: context,
                                      imagePath: 'assets/images/31.png',
                                      title: '雙手抬舉',
                                      screenSize: screenSize,
                                      isLandscape: true,
                                      onTap: () async {
                                        if (FFAppState().affectedside == null)
                                          return;
                                        else if (FFAppState().affectedside ==
                                            "右側")
                                          global.posenumber = 9;
                                        else
                                          global.posenumber = 33;
                                        setState(() {
                                          FFAppState().trainup = '雙手抬舉';
                                        });
                                        inputtime();
                                      },
                                    ),
                                    _buildExerciseItem(
                                      context: context,
                                      imagePath: 'assets/images/50.png',
                                      title: '聳肩旋轉',
                                      screenSize: screenSize,
                                      isLandscape: true,
                                      onTap: () async {
                                        if (FFAppState().affectedside == null)
                                          return;
                                        else if (FFAppState().affectedside ==
                                            "右側")
                                          global.posenumber = 10;
                                        else
                                          global.posenumber = 34;
                                        setState(() {
                                          FFAppState().trainup = '聳肩旋轉';
                                        });
                                        inputtime();
                                      },
                                    ),
                                    _buildExerciseItem(
                                      context: context,
                                      imagePath: 'assets/images/33.png',
                                      title: '洗澡動作',
                                      screenSize: screenSize,
                                      isLandscape: true,
                                      onTap: () async {
                                        if (FFAppState().affectedside == null)
                                          return;
                                        else if (FFAppState().affectedside ==
                                            "右側")
                                          global.posenumber = 11;
                                        else
                                          global.posenumber = 35;
                                        setState(() {
                                          FFAppState().trainup = '洗澡動作';
                                        });
                                        inputtime();
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        // 直向模式 (保持原始布局)
                        : Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              if (FFAppState().affectedside ==
                                                  null)
                                                return;
                                              else if (FFAppState()
                                                      .affectedside ==
                                                  "右側")
                                                global.posenumber = 6;
                                              else
                                                global.posenumber = 30;
                                              setState(() {
                                                FFAppState().trainup = '肩膀前舉';
                                              });
                                              inputtime();
                                            },
                                            child: Image.asset(
                                              'assets/images/28.png',
                                              width: screenSize.width * 0.35,
                                              height: screenSize.width * 0.35,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          Text(
                                            '肩膀前舉',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Poppins',
                                                  fontSize:
                                                      screenSize.width * 0.08,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              if (FFAppState().affectedside ==
                                                  null)
                                                return;
                                              else if (FFAppState()
                                                      .affectedside ==
                                                  "右側")
                                                global.posenumber = 7;
                                              else
                                                global.posenumber = 31;
                                              setState(() {
                                                FFAppState().trainup = '手肘前伸';
                                              });
                                              inputtime();
                                            },
                                            child: Image.asset(
                                              'assets/images/29.png',
                                              width: screenSize.width * 0.35,
                                              height: screenSize.width * 0.35,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          Text(
                                            '手肘前伸',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Poppins',
                                                  fontSize:
                                                      screenSize.width * 0.08,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              if (FFAppState().affectedside ==
                                                  null)
                                                return;
                                              else if (FFAppState()
                                                      .affectedside ==
                                                  "右側")
                                                global.posenumber = 8;
                                              else
                                                global.posenumber = 32;

                                              setState(() {
                                                FFAppState().trainup = '肩膀側舉';
                                              });
                                              inputtime();
                                            },
                                            child: Image.asset(
                                              'assets/images/30.png',
                                              width: screenSize.width * 0.35,
                                              height: screenSize.width * 0.35,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          Text(
                                            '肩膀側舉',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Poppins',
                                                  fontSize:
                                                      screenSize.width * 0.08,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              if (FFAppState().affectedside ==
                                                  null)
                                                return;
                                              else if (FFAppState()
                                                      .affectedside ==
                                                  "右側")
                                                global.posenumber = 9;
                                              else
                                                global.posenumber = 33;

                                              setState(() {
                                                FFAppState().trainup = '雙手抬舉';
                                              });
                                              inputtime();
                                            },
                                            child: Image.asset(
                                              'assets/images/31.png',
                                              width: screenSize.width * 0.35,
                                              height: screenSize.width * 0.35,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          Text(
                                            '雙手抬舉',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Poppins',
                                                  fontSize:
                                                      screenSize.width * 0.08,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              if (FFAppState().affectedside ==
                                                  null)
                                                return;
                                              else if (FFAppState()
                                                      .affectedside ==
                                                  "右側")
                                                global.posenumber = 10;
                                              else
                                                global.posenumber = 34;

                                              setState(() {
                                                FFAppState().trainup = '聳肩旋轉';
                                              });
                                              inputtime();
                                            },
                                            child: Image.asset(
                                              'assets/images/50.png',
                                              width: screenSize.width * 0.35,
                                              height: screenSize.width * 0.35,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          Text(
                                            '聳肩旋轉',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Poppins',
                                                  fontSize:
                                                      screenSize.width * 0.08,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              if (FFAppState().affectedside ==
                                                  null)
                                                return;
                                              else if (FFAppState()
                                                      .affectedside ==
                                                  "右側")
                                                global.posenumber = 11;
                                              else
                                                global.posenumber = 35;

                                              setState(() {
                                                FFAppState().trainup = '洗澡動作';
                                              });
                                              inputtime();
                                            },
                                            child: Image.asset(
                                              'assets/images/33.png',
                                              width: screenSize.width * 0.35,
                                              height: screenSize.width * 0.35,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          Text(
                                            '洗澡動作',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Poppins',
                                                  fontSize:
                                                      screenSize.width * 0.08,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              // 底部固定導航欄
              BottomNavigation(currentPage: 'trainupperbody2', isSubPage: true),
            ],
          ),
        ),
      ),
    );
  }
}

// 訓練項目組件 (橫向模式專用)
Widget _buildExerciseItem({
  required BuildContext context,
  required String imagePath,
  required String title,
  required Size screenSize,
  required bool isLandscape,
  required VoidCallback onTap,
}) {
  final screenWidth = screenSize.width;
  final screenHeight = screenSize.height;

  final imageSize = isLandscape ? screenHeight * 0.2 : screenWidth * 0.35;

  final fontSize = isLandscape ? screenHeight * 0.05 : screenWidth * 0.08;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap,
        child: Image.asset(
          imagePath,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.fill,
        ),
      ),
      SizedBox(height: screenHeight * 0.01),
      Text(
        title,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Poppins',
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
      ),
    ],
  );
}
