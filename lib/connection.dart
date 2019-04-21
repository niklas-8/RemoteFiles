import 'package:flutter/material.dart';
import 'package:ssh/ssh.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'custom_tooltip.dart';
import 'custom_show_dialog.dart';
import 'favorites_page.dart';
import 'main.dart';

class ConnectionPage extends StatefulWidget {
  ConnectionPage({Key key, this.address, this.port, this.username, this.passwordOrKey, this.path, this.map}) : super(key: key);

  String address;
  String port;
  String username;
  String passwordOrKey;
  String path;
  Map<String, String> map;

  connectToSftpMap(Map<String, String> map) {
    _ConnectionPageState()._connectToSftpMap(map);
  }

  connectToSftp({@required String address, String port, String username, String passwordOrKey, String path}) {
    _ConnectionPageState()._connectToSftp(address: address, port: port, username: username, passwordOrKey: passwordOrKey, path: path);
  }

  static Map<String, String> currentConnection = {};

  @override
  _ConnectionPageState createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> with TickerProviderStateMixin {
  var _refreshKey = GlobalKey<RefreshIndicatorState>();

  SSHClient _client;

  List<Map<String, String>> _fileInfos = [];
  bool _isLoaded = false;
  int _itemNum = FavoritesPage.favorites.length > 0 ? FavoritesPage.favorites.length : 1;
  bool _isLoading = false;
  bool _showProgressIndicator = false;
  bool _showHiddenFiles = false;

  String _directoryBefore = "";

  _connectToSftpMap(Map<String, String> map) {
    _connectToSftp(
      address: map["address"],
      port: map["port"],
      username: map["username"],
      passwordOrKey: map["passwordOrKey"],
      path: map["path"],
    );
  }

  _connectToSftp({@required String address, String port, String username, String passwordOrKey, String path}) async {
    ConnectionPage.currentConnection = {
      "address": address,
      "port": port != null ? port : "22",
      "username": username != null ? username : "",
      "passwordOrKey": passwordOrKey != null ? passwordOrKey : "",
      "path": path != null ? path : ""
    };
    _client = SSHClient(
      host: address,
      port: port != null && port != "" ? int.parse(port) : 22,
      username: username,
      passwordOrKey: passwordOrKey,
    );
    setState(() {
      _isLoading = true;
      _showProgressIndicatorAsync();
    });
    await _client.connect();
    await _client.connectSFTP();
    var _list = await _client.sftpLs(path != null && path != "" ? path : "/");
    _fileInfos = [];
    _fileInfos.length = _list.length;
    for (int i = 0; i < _list.length; i++) {
      _fileInfos[i] = {};
      _list[i].forEach((k, v) {
        setState(() {
          _fileInfos[i].addAll({k.toString(): v.toString()});
        });
      });
    }
    setState(() {
      _isLoading = false;
      _showProgressIndicator = false;
      _isLoaded = true;
      _itemNum = _fileInfos.length;
    });
  }

  Future<void> _refresh() async {
    await Future.delayed(Duration(milliseconds: 50));
    _connectToSftpMap(ConnectionPage.currentConnection);
    return null;
  }

  _connectToDirectoryBefore() {
    String current = ConnectionPage.currentConnection["path"];
    int lastSlashIndex;
    for (int i = 0; i < current.length - 1; i++) {
      if (current.substring(i, i + 1) == "/") {
        lastSlashIndex = i;
      }
    }
    _directoryBefore = current.substring(0, lastSlashIndex);
    _connectToSftp(
      address: ConnectionPage.currentConnection["address"],
      port: ConnectionPage.currentConnection["port"],
      username: ConnectionPage.currentConnection["username"],
      passwordOrKey: ConnectionPage.currentConnection["passwordOrKey"],
      path: _directoryBefore,
    );
  }

  _goToDirectory(String value) {
    _connectToSftp(
      address: ConnectionPage.currentConnection["address"],
      port: ConnectionPage.currentConnection["port"],
      username: ConnectionPage.currentConnection["username"],
      passwordOrKey: ConnectionPage.currentConnection["passwordOrKey"],
      path: value,
    );
  }

  _showProgressIndicatorAsync() async {
    await Future.delayed(Duration(milliseconds: 200));
    setState(() {
      _showProgressIndicator = !_showProgressIndicator;
    });
  }

  AnimationController _rotationController;

  @override
  void initState() {
    _rotationController = AnimationController(duration: const Duration(milliseconds: 100), vsync: this);
    _connectToSftp(
      address: widget.address,
      port: widget.port,
      username: widget.username,
      passwordOrKey: widget.passwordOrKey,
      path: widget.path,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        notchMargin: 4.0,
        shape: CircularNotchedRectangle(),
        elevation: 8.0,
        child: Container(
          height: 55.0,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.chevron_left),
                    onPressed: () => Navigator.pop(context),
                  ),
                  InkWell(
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      width: _isLoading ? constraints.maxWidth - 5 * 48.0 : constraints.maxWidth - 4 * 48.0, // 48.0 ~= IconButton width
                      height: 55.0, // 55.0 = BottomAppBar height,
                      padding: EdgeInsets.only(top: 18.0),
                      child: Text(
                        ConnectionPage.currentConnection["path"] != null
                            ? ConnectionPage.currentConnection["path"] != "" ? ConnectionPage.currentConnection["path"] : "/"
                            : "",
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, fontFamily: "GoogleSans"),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    onTap: () {
                      MyHomePage().showConnectionDialog(
                        context: context,
                        page: "connection",
                        primaryButton: RaisedButton(
                          color: Theme.of(context).accentColor,
                          splashColor: Colors.black12,
                          child: Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(right: 3.5, bottom: 2.0),
                                child: Icon(
                                  OMIcons.edit,
                                  size: 19.0,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "Edit",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                          padding: EdgeInsets.only(top: 8.0, bottom: 6.5, left: 12.0, right: 14.0),
                          elevation: .0,
                          onPressed: () {},
                        ),
                        hasSecondaryButton: true,
                        secondaryButton: FlatButton(
                          child: Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(right: 3.5, bottom: 2.0),
                                child: Icon(
                                  Icons.remove_circle_outline,
                                  size: 19.0,
                                ),
                              ),
                              Text("Disconnect"),
                            ],
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                          padding: EdgeInsets.only(top: 8.0, bottom: 6.5, left: 12.0, right: 14.0),
                          onPressed: () {
                            _client.disconnectSFTP();
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                  RotatedBox(
                    quarterTurns: 2,
                    child: CustomTooltip(
                      message: "Go to parent directory",
                      child: IconButton(
                        icon: Icon(Icons.subdirectory_arrow_right),
                        onPressed: () {
                          _connectToDirectoryBefore();
                        },
                      ),
                    ),
                  ),
                  CustomTooltip(
                    message: "Go to specific directory",
                    child: IconButton(
                      icon: Icon(Icons.youtube_searched_for),
                      onPressed: () {
                        _connectToSftp(
                          address: ConnectionPage.currentConnection["address"],
                          port: ConnectionPage.currentConnection["port"],
                          username: ConnectionPage.currentConnection["username"],
                          passwordOrKey: ConnectionPage.currentConnection["passwordOrKey"],
                          path: ConnectionPage.currentConnection["path"],
                        );
                        customShowDialog(
                          context: context,
                          builder: (context) {
                            return CustomAlertDialog(
                              title: Text("Go to directory", style: TextStyle(fontFamily: "GoogleSans", fontSize: 18.0)),
                              content: Container(
                                width: 260.0,
                                child: TextField(
                                  decoration: InputDecoration(labelText: "Path"),
                                  autofocus: true,
                                  onSubmitted: (String value) {
                                    _goToDirectory(value);
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  CustomTooltip(
                    message: _showHiddenFiles ? "Don't show hidden files" : "Show hidden files",
                    child: IconButton(
                      icon: Icon(_showHiddenFiles ? OMIcons.visibilityOff : OMIcons.visibility),
                      onPressed: () {
                        setState(() {
                          _showHiddenFiles = !_showHiddenFiles;
                        });
                      },
                    ),
                  ),
                  _showProgressIndicator
                      ? Container(
                          margin: EdgeInsets.only(left: 6.0),
                          height: 24.0,
                          width: 24.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.0,
                          ),
                        )
                      : Container(),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SpeedDial(
        heroTag: "fab",
        child: RotationTransition(
          turns: Tween(begin: .0, end: 0.125).animate(_rotationController),
          child: Icon(Icons.add),
        ),
        onOpen: () {
          _rotationController.forward(from: .0);
        },
        onClose: () {
          _rotationController.animateBack(.0);
        },
        children: [
          SpeedDialChild(
              label: "Upload File",
              labelStyle: TextStyle(fontFamily: "GoogleSans", fontWeight: FontWeight.w500),
              child: Icon(OMIcons.cloudUpload),
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).accentColor,
              elevation: 3.0,
              onTap: () {}),
          SpeedDialChild(
              label: "Create Folder",
              labelStyle: TextStyle(fontFamily: "GoogleSans", fontWeight: FontWeight.w500),
              child: Icon(OMIcons.createNewFolder),
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).accentColor,
              elevation: 3.0,
              onTap: () {}),
        ],
      ),
      body: SafeArea(
        child: Scrollbar(
          child: RefreshIndicator(
            key: _refreshKey,
            onRefresh: () => _refresh(),
            child: ListView.builder(
              itemCount: _itemNum,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: <Widget>[
                    _isLoaded
                        ? !_showHiddenFiles && _fileInfos[index]["filename"].substring(0, 1) == "."
                            ? Container()
                            : ListTile(
                                leading: _fileInfos[index]["isDirectory"] == "true" ? Icon(OMIcons.folder) : Icon(Icons.insert_drive_file),
                                title: Text(_fileInfos[index]["filename"]),
                                onTap: () {
                                  if (_fileInfos[index]["isDirectory"] == "true") {
                                    setState(() {
                                      _directoryBefore = ConnectionPage.currentConnection["path"];
                                    });
                                    _connectToSftp(
                                      address: ConnectionPage.currentConnection["address"],
                                      port: ConnectionPage.currentConnection["port"],
                                      username: ConnectionPage.currentConnection["username"],
                                      passwordOrKey: ConnectionPage.currentConnection["passwordOrKey"],
                                      path: ConnectionPage.currentConnection["path"] + "/" + _fileInfos[index]["filename"],
                                    );
                                  }
                                },
                              )
                        : index == 0
                            ? Container(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 60.0),
                                  child: Center(
                                    child: Text("No files found", style: TextStyle(fontSize: 16.0)),
                                  ),
                                ),
                              )
                            : Container(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}