import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/shared.dart';
import '../services/services.dart';
import 'pages.dart';

class SettingsPage extends StatefulWidget {
  final ConnectionPage currentConnectionPage;

  SettingsPage({this.currentConnectionPage});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  Widget _buildHeadline(
    String title, {
    bool hasSwitch = false,
    Function onChanged,
  }) {
    String sortLabel;
    if (hasSwitch) {
      if (SettingsVariables.sort == "name") {
        if (SettingsVariables.sortIsDescending) {
          sortLabel = "(Z-A)";
        } else {
          sortLabel = "(A-Z)";
        }
      } else {
        if (SettingsVariables.sortIsDescending) {
          sortLabel = "Newest";
        } else {
          sortLabel = "Oldest";
        }
      }
    }
    return Padding(
      padding: EdgeInsets.only(
        top: hasSwitch ? 8.0 : 19.0,
        bottom: hasSwitch ? .0 : 11.0,
        left: 18.0,
        right: hasSwitch ? 22.0 : 18.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
              fontFamily: SettingsVariables.accentFont,
              letterSpacing: 1.0,
              color: Theme.of(context).hintColor,
            ),
          ),
          hasSwitch
              ? Row(
                  children: <Widget>[
                    Text(
                      sortLabel.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        fontFamily: SettingsVariables.accentFont,
                        letterSpacing: 1.0,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    SizedBox(width: 6.0),
                    Switch(
                      activeThumbImage:
                          AssetImage("assets/arrow_drop_down.png"),
                      activeColor:
                          Provider.of<CustomTheme>(context).isLightTheme()
                              ? Colors.grey[50]
                              : Colors.grey[400],
                      activeTrackColor:
                          Provider.of<CustomTheme>(context).isLightTheme()
                              ? Colors.grey[300]
                              : Colors.grey[700],
                      inactiveThumbImage:
                          AssetImage("assets/arrow_drop_up.png"),
                      inactiveTrackColor:
                          Provider.of<CustomTheme>(context).isLightTheme()
                              ? Colors.grey[300]
                              : Colors.grey[700],
                      inactiveThumbColor:
                          Provider.of<CustomTheme>(context).isLightTheme()
                              ? Colors.grey[50]
                              : Colors.grey[400],
                      value: SettingsVariables.sortIsDescending,
                      onChanged: onChanged,
                    ),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _buildRadioListTile({
    @required String titleLabel,
    @required String value,
    @required bool isView,
  }) {
    return RadioListTile(
      activeColor: Theme.of(context).accentColor,
      title: Text(titleLabel),
      groupValue: isView ? SettingsVariables.view : SettingsVariables.sort,
      value: value,
      onChanged: (String radioValue) async {
        if (isView) {
          await SettingsVariables.setView(value);
        } else {
          await SettingsVariables.setSort(value);
          if (widget.currentConnectionPage != null) {
            widget.currentConnectionPage.sortFileInfos();
          }
        }
        setState(() {});
      },
    );
  }

  Widget _buildCheckboxListTile({
    @required String titleLabel,
    @required bool value,
    @required ValueChanged<bool> onChanged,
  }) {
    return CheckboxListTile(
      activeColor: Theme.of(context).accentColor,
      title: Padding(
        padding: EdgeInsets.only(left: 3.0),
        child: Text(titleLabel),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSaveToWidget() {
    if (Platform.isIOS) {
      return Container();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildHeadline("Save files to:"),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 19.0,
              vertical: 4.0,
            ),
            child: Container(
              child: TextField(
                controller: _downloadPathTextController,
                decoration: InputDecoration(
                  labelText: "Path",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).accentColor,
                      width: 2.0,
                    ),
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CustomTooltip(
                        message: "Clear",
                        child: CustomIconButton(
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () {
                            SettingsVariables.setDownloadDirectory("").then(
                                (_) => _downloadPathTextController.text = "");
                          },
                        ),
                      ),
                      CustomTooltip(
                        message: "Set to default",
                        child: CustomIconButton(
                          icon: Icon(
                            Icons.settings_backup_restore,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () {
                            SettingsVariables.setDownloadDirectoryToDefault()
                                .then((Directory dir) {
                              _downloadPathTextController.text = dir.path;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                onChanged: (String value) async {
                  await SettingsVariables.setDownloadDirectory(value);
                },
              ),
            ),
          ),
          Divider(),
        ],
      );
    }
  }

  var _downloadPathTextController =
      TextEditingController(text: SettingsVariables.downloadDirectory.path);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 55.0,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                "Settings",
                style: TextStyle(
                  fontFamily: SettingsVariables.accentFont,
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).detach(),
        child: SafeArea(
          child: Scrollbar(
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                SizedBox(height: 14.0),
                _buildSaveToWidget(),
                _buildHeadline("View"),
                _buildRadioListTile(
                  titleLabel: "List",
                  value: "list",
                  isView: true,
                ),
                _buildRadioListTile(
                  titleLabel: "Detailed",
                  value: "detailed",
                  isView: true,
                ),
                _buildRadioListTile(
                  titleLabel: "Grid",
                  value: "grid",
                  isView: true,
                ),
                Divider(),
                _buildHeadline(
                  "Sort",
                  hasSwitch: true,
                  onChanged: (bool value) async {
                    await SettingsVariables.setSortIsDescending(value);
                    if (widget.currentConnectionPage != null) {
                      widget.currentConnectionPage.sortFileInfos();
                    }
                    setState(() {});
                  },
                ),
                _buildRadioListTile(
                  titleLabel: "Name",
                  value: "name",
                  isView: false,
                ),
                _buildRadioListTile(
                  titleLabel: "Modification Date",
                  value: "modificationDate",
                  isView: false,
                ),
                _buildRadioListTile(
                  titleLabel: "Last Access",
                  value: "lastAccess",
                  isView: false,
                ),
                Divider(),
                _buildHeadline("Appearance"),
                ListTile(
                  title: Text("Theme"),
                  onTap: () {
                    customShowDialog(
                      context: context,
                      builder: (context) => CustomAlertDialog(
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 12.0),
                            content:
                                StatefulBuilder(builder: (context, setState) {
                              return Consumer<CustomTheme>(
                                  builder: (context, model, child) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    RadioListTile(
                                      activeColor:
                                          Theme.of(context).accentColor,
                                      title: Text("Automatic"),
                                      value: "automatic",
                                      groupValue: model.themeValue,
                                      onChanged: (String value) async {
                                        await model.setThemeValue(value);
                                        setState(() {});
                                      },
                                    ),
                                    RadioListTile(
                                      activeColor:
                                          Theme.of(context).accentColor,
                                      title: Text("Light"),
                                      value: "light",
                                      groupValue: model.themeValue,
                                      onChanged: (String value) async {
                                        await model.setThemeValue(value);
                                        setState(() {});
                                      },
                                    ),
                                    RadioListTile(
                                      activeColor:
                                          Theme.of(context).accentColor,
                                      title: Text("Dark"),
                                      value: "dark",
                                      groupValue: model.themeValue,
                                      onChanged: (String value) async {
                                        await model.setThemeValue(value);
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                );
                              });
                            }),
                          ),
                    );
                  },
                ),
                _buildCheckboxListTile(
                  titleLabel: "Show hidden files",
                  value: SettingsVariables.showHiddenFiles,
                  onChanged: (bool value) async {
                    await SettingsVariables.setShowHiddenFiles(value);
                    setState(() {});
                  },
                ),
                ListTile(
                  title: Text("Unit for filesize"),
                  onTap: () {
                    customShowDialog(
                      context: context,
                      builder: (context) => CustomAlertDialog(
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 12.0),
                            content:
                                StatefulBuilder(builder: (context, setState) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  RadioListTile(
                                    activeColor: Theme.of(context).accentColor,
                                    title: Text("Automatic"),
                                    value: "automatic",
                                    groupValue: SettingsVariables.filesizeUnit,
                                    onChanged: (String value) async {
                                      if (widget.currentConnectionPage != null)
                                        await SettingsVariables.setFilesizeUnit(
                                            value,
                                            widget.currentConnectionPage);
                                      setState(() {});
                                    },
                                  ),
                                  RadioListTile(
                                    activeColor: Theme.of(context).accentColor,
                                    title: Text("Byte"),
                                    value: "B",
                                    groupValue: SettingsVariables.filesizeUnit,
                                    onChanged: (String value) async {
                                      if (widget.currentConnectionPage != null)
                                        await SettingsVariables.setFilesizeUnit(
                                            value,
                                            widget.currentConnectionPage);
                                      setState(() {});
                                    },
                                  ),
                                  RadioListTile(
                                    activeColor: Theme.of(context).accentColor,
                                    title: Text("Kilobyte"),
                                    value: "KB",
                                    groupValue: SettingsVariables.filesizeUnit,
                                    onChanged: (String value) async {
                                      if (widget.currentConnectionPage != null)
                                        await SettingsVariables.setFilesizeUnit(
                                            value,
                                            widget.currentConnectionPage);
                                      setState(() {});
                                    },
                                  ),
                                  RadioListTile(
                                    activeColor: Theme.of(context).accentColor,
                                    title: Text("Megabyte"),
                                    value: "MB",
                                    groupValue: SettingsVariables.filesizeUnit,
                                    onChanged: (String value) async {
                                      if (widget.currentConnectionPage != null)
                                        await SettingsVariables.setFilesizeUnit(
                                            value,
                                            widget.currentConnectionPage);
                                      setState(() {});
                                    },
                                  ),
                                  RadioListTile(
                                    activeColor: Theme.of(context).accentColor,
                                    title: Text("Gigabyte"),
                                    value: "GB",
                                    groupValue: SettingsVariables.filesizeUnit,
                                    onChanged: (String value) async {
                                      if (widget.currentConnectionPage != null)
                                        await SettingsVariables.setFilesizeUnit(
                                            value,
                                            widget.currentConnectionPage);
                                      setState(() {});
                                    },
                                  ),
                                ],
                              );
                            }),
                          ),
                    );
                  },
                ),
                Divider(),
                _buildHeadline("Other"),
                ListTile(
                  title: Text("Delete all connections"),
                  onTap: () {
                    customShowDialog(
                      context: context,
                      builder: (context) => CustomAlertDialog(
                            title: Text(
                              "Delete all connections?\nThis cannot be undone.",
                              style: TextStyle(
                                fontFamily: SettingsVariables.accentFont,
                              ),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                padding: EdgeInsets.only(
                                    top: 8.5,
                                    bottom: 8.0,
                                    left: 14.0,
                                    right: 14.0),
                                child: Text("Cancel"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              RaisedButton(
                                color: Theme.of(context).accentColor,
                                splashColor: Colors.black12,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                padding: EdgeInsets.only(
                                    top: 8.5,
                                    bottom: 8.0,
                                    left: 14.0,
                                    right: 14.0),
                                child: Text(
                                  "OK",
                                  style: TextStyle(
                                    color: Provider.of<CustomTheme>(context)
                                            .isLightTheme()
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                elevation: .0,
                                onPressed: () {
                                  HomePage.favoritesPage.removeAllFromJson();
                                  HomePage.favoritesPage
                                      .setConnectionsFromJson();
                                  HomePage.recentlyAddedPage
                                      .removeAllFromJson();
                                  HomePage.recentlyAddedPage
                                      .setConnectionsFromJson();
                                  Navigator.pop(context);
                                },
                              ),
                              SizedBox(width: .0),
                            ],
                          ),
                    );
                  },
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
