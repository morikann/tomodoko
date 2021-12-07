import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ImageManager {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isFileSelected = false;

  bool get isFileSelected {
    return _isFileSelected;
  }

  File? get imageFile {
    return _imageFile;
  }

  ImageProvider getImageProvider(imgPath) {
    // 画像の選択があったら表示
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    }

    // cloud_storageに画像があったら表示
    if (imgPath != null) {
      return NetworkImage(imgPath);
    }

    // 何もなかったらデフォルト画像
    return const AssetImage('images/default.png');
  }

  Future<void> getImageFromCamera() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _isFileSelected = true;
      // 画像の選択があったらbottomSheetを閉じる
      // Navigator.of(context).pop();
      // setState(() {
      //   _imageFile = File(pickedFile.path);
      // });
      _imageFile = File(pickedFile.path);
    } else {
      _isFileSelected = false;
      print('no camera image selected');
    }
  }

  Future<void> getImageFromGallery() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // 画像の選択があったらbottomSheetを閉じる
      // Navigator.of(context).pop();
      // setState(() {
      //   _imageFile = File(pickedFile.path);
      // });
      _isFileSelected = true;
      _imageFile = File(pickedFile.path);
    } else {
      _isFileSelected = false;
      print('no gallery image selected');
    }
  }
}
