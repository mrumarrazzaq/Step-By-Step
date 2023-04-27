import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stepbystep/config.dart';

class PickFileApi {
  static Future<String> pickImage(ImageSource imageSource) async {
    String image = '';
    final ImagePicker picker = ImagePicker();
    final result = await picker.pickImage(
      source: imageSource,
    );
    final path = result!.path;
    log('------------------------------------');
    log('Image Path : $path');
    image = path;
    String imageName = path.split('/').last;
    log(imageName);
    String url = await uploadImage(path, imageName);
    return url;
  }

  static Future<String> pickImageSpecial(ImageSource imageSource) async {
    String image = '';
    final ImagePicker picker = ImagePicker();
    final result = await picker.pickImage(
      source: imageSource,
    );
    final path = result!.path;
    log('------------------------------------');
    log('Image Path : $path');
    image = path;
    String imageName = path.split('/').last;
    log(imageName);
    String url =
        await uploadImageToSpecifiedLocation('profileImages', path, imageName);
    return url;
  }

  static Future<String> uploadImageToSpecifiedLocation(
      String directoryName, String path, String imageName) async {
    String url = '';
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("$directoryName/$currentUserEmail");
    UploadTask uploadTask = ref.putFile(File(path));
    await uploadTask.whenComplete(() async {
      url = await ref.getDownloadURL();
      log('----------------------------------');
      log('url : $url');
      return url;
    }).catchError((onError) {
      log('---------------------------------------');
      log('Error while uploading image');
      log(onError);
    });
    return url;
  }

  static Future<String> uploadImage(String path, String imageName) async {
    String url = '';
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref =
        storage.ref().child("ChatImages/$imageName $currentUserEmail");
    UploadTask uploadTask = ref.putFile(File(path));
    await uploadTask.whenComplete(() async {
      url = await ref.getDownloadURL();
      log('----------------------------------');
      log('url : $url');
      return url;
    }).catchError((onError) {
      log('---------------------------------------');
      log('Error while uploading image');
      log(onError);
    });
    return url;
  }

  static Future<List<String>> pickFile() async {
    List<String> urls = [];
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc', 'png'],
      allowMultiple: true,
    );
    if (result != null) {
      Uint8List? fileBytes = result.files.first.bytes;
      final filesPath = result.paths;
      log('__________________________');
      log(fileBytes.toString());
      log('__________________________');
      List<String> filesName = [];
      for (var path in filesPath) {
        filesName.add(path!.split('/').last);
      }
      log(filesPath.toString());
      log(filesName.toString());
      urls = await uploadFiles(filesPath, filesName);
      return urls;
    }
    return urls;
  }

  static Future<List<String>> pickSingleFile() async {
    List<String> urls = [];
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'pdf',
        'doc',
        'png',
        'zip',
        'ppt',
        'docx',
        'xlsx'
      ],
      allowMultiple: false,
    );
    if (result != null) {
      Uint8List? fileBytes = result.files.first.bytes;
      final filesPath = result.paths;
      log('__________________________');
      log(fileBytes.toString());
      log('__________________________');
      List<String> filesName = [];
      for (var path in filesPath) {
        filesName.add(path!.split('/').last);
      }
      log(filesPath.toString());
      log(filesName.toString());
      urls = await uploadSingleFiles(filesPath, filesName);
      urls.add(filesName.toString());
      return urls;
    }
    return urls;
  }

  static Future<List<String>> uploadSingleFiles(
      List<String?> filesPath, List<String> filesName) async {
    List<String> urlList = [];
    FirebaseStorage storage = FirebaseStorage.instance;
    for (int i = 0; i < filesPath.length; i++) {
      Reference ref = storage
          .ref()
          .child("UploadedTaskFiles/${filesName[i]} $currentUserEmail");
      UploadTask uploadTask = ref.putFile(File(filesPath[i]!));
      await uploadTask.whenComplete(() async {
        String url = await ref.getDownloadURL();
        urlList.add(url);
        log('----------------------------------');
        log('url : $url');
      }).catchError((onError) {
        log('Error while uploading file');
        log(onError);
      });
    }
    return urlList;
  }

  static Future<List<String>> uploadFiles(
      List<String?> filesPath, List<String> filesName) async {
    List<String> urlList = [];
    FirebaseStorage storage = FirebaseStorage.instance;
    for (int i = 0; i < filesPath.length; i++) {
      Reference ref = storage
          .ref()
          .child("UploadedChatFiles/${filesName[i]} $currentUserEmail");
      UploadTask uploadTask = ref.putFile(File(filesPath[i]!));
      await uploadTask.whenComplete(() async {
        String url = await ref.getDownloadURL();
        urlList.add(url);
        log('----------------------------------');
        log('url : $url');
      }).catchError((onError) {
        log('Error while uploading file');
        log(onError);
      });
    }
    return urlList;
  }
}
