import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firestorage/firebase_options.dart';

import 'dart:io' as io;

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  

  Future<void> _addImage() async{
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      dialogTitle: 'Выбор изображения'
    );

    if (result != null) {

      final size = result.files.first.size;
      final file = io.File(result.files.single.path!);
      final fileExtensions = result.files.first.extension!;
      print("размер:$size file:${file.path} fileExtensions:${fileExtensions}");

      FirebaseStorage.instance.ref().child("images").putFile(file);

    }
  }

  Future<void> initImage() async {
    fullpath.clear();
    final storageReference = FirebaseStorage.instance.ref().list();
    final list = await storageReference;
    list.items.forEach((element) async {
      final url = await element.getDownloadURL();
      fullpath.add(ModelTest(url, element.name));
      setState(() {});
    });
  }

    @override
  void initState() {
    initImage().then(
      (value) {},
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
     return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () async {
                await initImage();
              },
              icon: Icon(Icons.refresh))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: ListView.builder(
                itemCount: fullpath.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: InkWell(
                      onLongPress: () async {
                        link = '';
                        await FirebaseStorage.instance
                            .ref("/" + fullpath[index].name)
                            .delete();
                        await initImage();
                        setState(() {});
                      },
                      onTap: () {
                        setState(() {
                          link = fullpath[index].url;
                        });
                      },
                      child: ListTile(
                        title: Text(fullpath[index].name),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: Image.network(
                link,
                errorBuilder: (context, error, stackTrace) {
                  return Text('Ошибка');
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addImage,
        tooltip: 'Add Image',
        child: const Icon(Icons.add),
      ),
    );
  }
  
}
