

import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final picker = ImagePicker();
  final pdf = pw.Document();
  List<File> _image =[];
  
  
  
  Future getImage(ImageSource source) async{
    final pickedFile = await picker.pickImage(source: source);
    setState(() {
      if(pickedFile !=null){
        _image.add(File(pickedFile.path));
      }else{
        print("No image selected");
      }
    });
  }


  Future<void> createPDF() async{
    for(var img in _image){
      final image = pw.MemoryImage(img.readAsBytesSync());
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(child: pw.Image(image));

        },
      ));
    }
  }
  void showPrintedMessage(String title, String msg){
    Flushbar(
      title: title,
      message: msg,
      duration: Duration(
        seconds: 3
      ),
      icon: Icon(
        Icons.save_alt_rounded,
        color: Colors.green,
      ),
    )..show(context);
  }


  Future<void> savePDF()async{
    try{
      final downloadDir = await getApplicationDocumentsDirectory();
      if(downloadDir != null){
        final file = File("${downloadDir.path}/${DateTime.now().microsecondsSinceEpoch}");
        await file.writeAsBytes(await pdf.save());
        print(file);
       showPrintedMessage("Success", "Saved to Download folder $file");
      }else{
        showPrintedMessage("Error", "Unable to access Download folder");
      }

    }catch(e){
     showPrintedMessage("Error", e.toString());

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.restart_alt_rounded,color: Colors.white,),
          onPressed: (){
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage(),));

          },
        ),
        centerTitle: true,
        backgroundColor: Colors.purple,
        title: Text("PDF",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        actions: [
          IconButton(onPressed: (){
            savePDF();
          }, icon: Icon(Icons.picture_as_pdf_rounded,color: Colors.white,)),
        ],
      ),
      body: _image.isNotEmpty ? ListView.builder(
        itemCount: _image.length,
          itemBuilder: (context, index) => Container(
            height: 400,
            width: double.infinity,
            margin: EdgeInsets.all(8),
            child: Image.file(
              _image[index]
                  ,fit: BoxFit.cover,
            ),
          ),
      ):Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: Radius.circular(20),
                  dashPattern: [10,10],
                  color: Colors.black,
                  strokeWidth: 2,
                  child: Padding(padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: 520,
                      width: 350,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.pink[50],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.photo_library_rounded,size: 60,color: Colors.purpleAccent[400],),
                          SizedBox(
                            height: 20,
                          ),
                          Text("No image is selected",style: TextStyle(fontSize: 17),),
                        ],
                      ),
                    ),
                  )
              ),
            )

          ],
        ),
      ),

      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            backgroundColor: Colors.purple[400],
              onPressed: ()
              =>getImage(ImageSource.gallery),
              
            child: Icon(Icons.photo_library_rounded,color: Colors.white,),

          ),
          SizedBox(width: 56,),
          FloatingActionButton(
            heroTag: "btn2",
            backgroundColor: Colors.purple[400],
              onPressed: ()=>getImage(ImageSource.camera),
            child: Icon(Icons.camera_alt_rounded,color: Colors.white,),
          )
        ],
      ),
    );
  }
}

