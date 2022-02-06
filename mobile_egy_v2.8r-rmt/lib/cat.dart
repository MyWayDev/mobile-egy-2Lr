import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:path_provider/path_provider.dart';

class Cat extends StatefulWidget {
  final String pdfUrl;
  Cat({@required this.pdfUrl});
  @override
  _CatState createState() => new _CatState();
}

class _CatState extends State<Cat> {
  String pathPDF = "";
  bool _isLoading = true;
  String searchResult = '';
  File pdfFile;
  PdfViewerController _pdfViewerController;

  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final TextEditingController controller = new TextEditingController();

  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    super.initState();
    /*
    createFileOfPdfUrl().then((f) {
      setState(() {
        pathPDF = f.path;

        print(pathPDF);
      });
    });*/
    downloadPdfFile(widget.pdfUrl).then((f) {
      pdfFile = f;
      pathPDF = f.path;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<File> downloadPdfFile(String pdfUrl) async {
    final url = pdfUrl;
    final filename = url.substring(url.lastIndexOf("/") + 1);
    String dir = (await getTemporaryDirectory()).path;
    File file = new File('$dir/$filename');
    bool exist = false;
    try {
      await file.length().then((len) {
        exist = true;
      });
    } catch (e) {
      print(e);
    }
    if (!exist) {
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      await file.writeAsBytes(bytes);
    }
    setState(() => _isLoading = false);
    return file;
  }

  Future<File> createFileOfPdfUrl() async {
    final url = // "http://conorlastowka.com/book/CitationNeededBook-Sample.pdf";
        'https://firebasestorage.googleapis.com/v0/b/mobile-coco.appspot.com/o/Cat%2FMorocco72019-compressed.pdf?alt=media&token=e8990df3-f357-44c7-9c69-228d230235c3';
    final filename = url.substring(url.lastIndexOf("/") + 1);

    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;

    File file = new File('$dir/$filename');
    //print('directory:$dir =>filename:$filename =>file:$file');

    //if (file == baseName()) {}

    await file.writeAsBytes(bytes);
    setState(() => _isLoading = false);
    return file;
  }

  /* @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: ColorLoader2(),
          )
        : ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model) {
            return PDFViewerScaffold(
                primary: true,
                appBar: AppBar(
                  centerTitle: true,
                  title: Text("الكاتالوج"),
                  actions: <Widget>[],
                ),
                path: pathPDF);
          });
  }*/
  PdfTextSearchResult _searchResult;
  onSearchTextChanged(String text) {
    setState(() {
      searchResult = text;
    });
    if (text.isEmpty) {
      setState(() {});
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('الكاتالوج')),
        actions: <Widget>[
          Card(
            child: ListTile(
              leading: Icon(
                Icons.search,
                size: 22.0,
              ),
              title: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "",
                  border: InputBorder.none,
                ),
                // style: TextStyle(fontSize: 18.0),
                onChanged: onSearchTextChanged(controller.text),
              ),
              trailing: IconButton(
                alignment: AlignmentDirectional.centerEnd,
                icon: Icon(Icons.cancel, size: 20.0),
                onPressed: () {
                  controller.clear();
                },
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () async {
              _searchResult =
                  await _pdfViewerController?.searchText(searchResult);
              setState(() {});
            },
          ),
          Visibility(
            visible: _searchResult?.hasResult ?? false,
            child: IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _searchResult.clear();
                });
              },
            ),
          ),
          Visibility(
            visible: _searchResult?.hasResult ?? false,
            child: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_up,
                color: Colors.white,
              ),
              onPressed: () {
                _searchResult?.previousInstance();
              },
            ),
          ),
          Visibility(
            visible: _searchResult?.hasResult ?? false,
            child: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
              onPressed: () {
                _searchResult?.nextInstance();
              },
            ),
          ),
        ],
      ),
      /*bottomSheet: SfPdfViewer.network(
        widget.pdfUrl,
        searchTextHighlightColor: Colors.pink,
        controller: _pdfViewerController,
        key: _pdfViewerKey,
      ),*/
      body: SfPdfViewer.file(
        pdfFile,
        searchTextHighlightColor: Colors.pink,
        controller: _pdfViewerController,
        key: _pdfViewerKey,
      ),
    );
  }
}
