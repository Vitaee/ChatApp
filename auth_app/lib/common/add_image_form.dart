// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddImageForm extends StatelessWidget {
  final String imagePath;
  final Function(String) onChanged;

  const AddImageForm({
    required this.imagePath,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget placeHolder = Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
          color: Colors.blue, borderRadius: BorderRadius.circular(50)),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => onAddImage(context),
          child:
              imagePath == "null" ? placeHolder : ImageWidget(image: imagePath),
        ),
        SizedBox(height: 5),
        Text(
          "Add profile image",
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  onAddImage(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 40,
                  child: GestureDetector(
                    onTap: () => showCamera(context),
                    child: Text("Add from camera"),
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: GestureDetector(
                    onTap: () => showGallery(context),
                    child: Text("Add from library"),
                  ),
                )
              ],
            ));
  }

  showCamera(BuildContext context) {
    Navigator.of(context).pop();
    showImagePicker(ImageSource.camera);
  }

  showGallery(BuildContext context) {
    Navigator.of(context).pop();
    showImagePicker(ImageSource.gallery);
  }

  showImagePicker(ImageSource imageSource) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? image =
        await imagePicker.pickImage(source: imageSource, imageQuality: 70);

    if (image != null) {
      onChanged(image.path);
    }
  }
}

class ImageWidget extends StatelessWidget {
  final String image;

  const ImageWidget({
    Key? key,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool validURL = Uri.parse(image).isAbsolute;
    return Container(
      height: 100,
      width: 100,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: validURL
            ? Image.network(
                image,
                fit: BoxFit.cover,
              )
            : Image.file(
                File(image),
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
