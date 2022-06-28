import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class Upload extends StatefulWidget {
  const Upload({Key? key}) : super(key: key);

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  var genre = '';
  var state = 'upload';

  Widget getWidget() {
    if (state == 'upload') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Silahkan Upload Audio',
            style: TextStyle(
              fontSize: 23,
              color: Color(0xFF006C6E),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 25),
          InkWell(
            onTap: () async {
              final result =
                  (await FilePicker.platform.pickFiles())?.files.first;

              if (result == null) return;
              if (result.path == null) return;

              var req = http.MultipartRequest(
                  'POST',
                  Uri.parse(
                      'https://3cc0-182-253-116-221.ap.ngrok.io/deteksi'));
              req.files.add(
                http.MultipartFile(
                  'file',
                  File(result.path!).readAsBytes().asStream(),
                  File(result.path!).lengthSync(),
                  filename: result.path!.split("/").last,
                ),
              );
              setState(() {
                state = 'loading';
              });
              var streamedRes = await req.send();

              if (streamedRes.statusCode == 200) {
                var res = await http.Response.fromStream(streamedRes);
                if (res.statusCode == 200) {
                  var decode = jsonDecode(res.body) as Map<String, dynamic>;
                  genre = decode['genre'];
                  setState(() {
                    state = 'done';
                  });
                  return;
                } else {
                  return;
                }
              } else {
                return;
              }
            },
            child: Container(
              width: 100,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text(
                'Upload',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (state == 'loading') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Mohon Tunggu',
            style: TextStyle(
              fontSize: 23,
              color: Color(0xFF006C6E),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Biarkan kami mendeteksi musik ini\nsejenak',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF006C6E),
            ),
          ),
          const SizedBox(height: 35),
          Image.asset(
            'assets/images/loading.png',
            width: 258,
          ),
          const SizedBox(height: 25),
          const Text(
            'Mendeteksi musik....',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF006C6E),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      );
    } else if (state == 'done') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Selesai',
            style: TextStyle(
              fontSize: 23,
              color: Color(0xFF006C6E),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 35),
          Image.asset(
            'assets/images/loading.png',
            width: 258,
          ),
          const SizedBox(height: 25),
          const Text(
            'Genre musikmu adalah',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF006C6E),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            genre.toString()[0].toUpperCase() +
                genre.toString().substring(1).toLowerCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 33,
              color: Color(0xFFFF6B6B),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 50),
          IconButton(
            onPressed: () {
              setState(() {
                state = 'upload';
              });
            },
            icon: const Icon(
              Icons.home_outlined,
              color: Color(0xFF868A91),
              size: 35,
            ),
          )
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: getWidget(),
        ),
      ),
    );
  }
}
