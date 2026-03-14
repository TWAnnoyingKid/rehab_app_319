import 'package:flutter/material.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import '../utils/ip_manager.dart';
import 'ip_config_model.dart';
export 'ip_config_model.dart';

class IpConfigWidget extends StatefulWidget {
  const IpConfigWidget({Key? key}) : super(key: key);

  @override
  _IpConfigWidgetState createState() => _IpConfigWidgetState();
}

class _IpConfigWidgetState extends State<IpConfigWidget> {
  late IpConfigModel _model;
  final IpManager _ipManager = IpManager();
  bool _isLoading = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _model = IpConfigModel();
    _model.initState(context);
    _model.ipController.text = _ipManager.displayIp;
  }

  @override
  void dispose() {
    _model.dispose();
    _unfocusNode.dispose();
    super.dispose();
  }

  Future<void> _setNewIp() async {
    if (_model.ipController.text.trim().isEmpty) {
      _showDialog('錯誤', 'IP地址不能為空');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _ipManager.setIp(_model.ipController.text.trim());

      if (success) {
        _showDialog('設定成功', 'IP已設定為 ${_ipManager.displayIp}', onConfirm: () {
          Navigator.of(context).pop();
        });
      } else {
        _showDialog('錯誤', '設定IP失敗，請重試');
      }
    } catch (e) {
      _showDialog('錯誤', '設定過程中發生錯誤：$e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetToLegacy() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _ipManager.resetToLegacy();

      if (success) {
        setState(() {
          _model.ipController.text = _ipManager.displayIp;
        });
        _showDialog('重設成功', 'IP已重設為舊設定');
      } else {
        _showDialog('錯誤', '重設失敗，請重試');
      }
    } catch (e) {
      _showDialog('錯誤', '重設過程中發生錯誤：$e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDialog(String title, String content, {VoidCallback? onConfirm}) {
    showDialog(
      context: context,
      builder: (alertDialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(alertDialogContext);
                if (onConfirm != null) {
                  onConfirm();
                }
              },
              child: Text('確定'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFF96B7FF),
        appBar: AppBar(
          backgroundColor: Color(0xFF96B7FF),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'IP 設定',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 22,
                ),
          ),
          centerTitle: true,
          elevation: 2,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 5,
                          color: Color(0x33000000),
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '目前IP設定',
                          style: FlutterFlowTheme.of(context)
                              .headlineSmall
                              .override(
                                fontFamily: 'Poppins',
                                color: Color(0xFF2B347C),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          _ipManager.displayIp,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Poppins',
                                    color: Color(0xFF57636C),
                                    fontSize: 16,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 5,
                          color: Color(0x33000000),
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '新IP設定',
                          style: FlutterFlowTheme.of(context)
                              .headlineSmall
                              .override(
                                fontFamily: 'Poppins',
                                color: Color(0xFF2B347C),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _model.ipController,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: '請輸入IP地址',
                            hintText: '例如：163.15.164.85:10073',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFFE0E3E7),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF4B39EF),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                  ),
                          keyboardType: TextInputType.url,
                        ),
                        SizedBox(height: 10),
                        Text(
                          '提示：系統會自動添加 http:// 和 /flutterphp/ 路徑',
                          style:
                              FlutterFlowTheme.of(context).bodySmall.override(
                                    fontFamily: 'Poppins',
                                    color: Color(0xFF57636C),
                                    fontSize: 12,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FFButtonWidget(
                        onPressed: _isLoading ? null : _resetToLegacy,
                        text: '測試舊設定',
                        options: FFButtonOptions(
                          width: screenSize.width * 0.4,
                          height: 50,
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          iconPadding:
                              EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          color: Color(0xFFFF8C42),
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                          elevation: 2,
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      FFButtonWidget(
                        onPressed: _isLoading ? null : _setNewIp,
                        text: _isLoading ? '設定中...' : '設定IP',
                        options: FFButtonOptions(
                          width: screenSize.width * 0.4,
                          height: 50,
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          iconPadding:
                              EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          color:
                              _isLoading ? Colors.grey[300] : Color(0xFF4B39EF),
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    fontFamily: 'Poppins',
                                    color: _isLoading
                                        ? Colors.grey[600]
                                        : Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                          elevation: _isLoading ? 0 : 2,
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.yellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '使用說明：',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Poppins',
                                    color: Color(0xFF2B347C),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '• 輸入新的IP地址後點擊「設定IP」\n'
                          '• 點擊「測試舊設定」可恢復原始設定\n'
                          '• 設定會自動儲存，重新啟動後仍然有效\n'
                          '• 預設IP：163.15.164.85:10073',
                          style:
                              FlutterFlowTheme.of(context).bodySmall.override(
                                    fontFamily: 'Poppins',
                                    color: Color(0xFF57636C),
                                    fontSize: 12,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
