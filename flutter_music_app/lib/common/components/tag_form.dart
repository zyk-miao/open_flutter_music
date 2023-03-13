import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:music_common/api/api.dart';
import 'package:music_common/entity/response_entity.dart';
import 'package:music_common/entity/tag.dart';

import '../function.dart';

class TagForm extends StatefulWidget {
  const TagForm({this.tag, Key? key}) : super(key: key);
  final Tag? tag;

  @override
  State<TagForm> createState() => _TagFormState();
}

class _TagFormState extends State<TagForm> {
  final TextEditingController _tagNameController = TextEditingController();
  File? file;
  final GlobalKey _formKey = GlobalKey();

  _addTag() async {
    final navigator = Navigator.of(context);
    if ((_formKey.currentState as FormState).validate()) {
      var filePath = file?.path;
      // var name =
      // filePath!.substring(filePath.lastIndexOf("/") + 1, filePath.length);
      //var suffix = name.substring(name.lastIndexOf(".") + 1, name.length);//似乎没用
      var formData = FormData.fromMap({
        'file':
            filePath == null ? null : await MultipartFile.fromFile(filePath),
      });
      ResponseEntity response =
          await addTag(Tag(tagName: _tagNameController.text), formData: formData);
      if (response.code == '200') {
        initTagList();
        navigator.pop();
      }
    }
  }

  _putTag() async {
    final navigator = Navigator.of(context);
    if ((_formKey.currentState as FormState).validate()) {
      var filePath = file?.path;
      // var name =
      // filePath!.substring(filePath.lastIndexOf("/") + 1, filePath.length);
      //var suffix = name.substring(name.lastIndexOf(".") + 1, name.length);//似乎没用
      ResponseEntity response = await putTag(
          Tag(id: widget.tag!.id, tagName: _tagNameController.text), filePath: filePath);

      if (response.code == '200') {
        var tag = Tag.fromJson(response.data);
        if (tag.coverImg != null) {
          CachedNetworkImage.evictFromCache(tag.coverImg!);
        }
        await initTagList();
        navigator.pop();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tagNameController.text = widget.tag?.tagName ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          MaterialButton(
            onPressed: () async {
              final ImagePicker picker = ImagePicker();
              // Pick an image
              final XFile? image =
                  await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                setState(() {
                  file = File(image.path);
                });
              }
            },
            child: file == null
                ? ((widget.tag == null || widget.tag?.coverImg == null)
                    ? Image.asset(
                        "img/default.jpg",
                        fit: BoxFit.fill,
                      )
                    : CachedNetworkImage(
                        imageUrl: widget.tag!.coverImg!,
                      ))
                : Image.file(
                    file!,
                    fit: BoxFit.fill,
                  ),
          ),
          TextFormField(
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            controller: _tagNameController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              icon: Icon(Icons.drive_file_rename_outline_rounded),
              labelText: "歌单名",
              hintText: "歌单名",
            ),
            validator: (v) {
              return v!.trim().isNotEmpty ? null : "歌单名不能为空";
            },
          ),
          Container(
              width: double.infinity,
              margin: const EdgeInsets.all(10),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue)),
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        if (widget.tag != null && widget.tag?.id != null) {
                          _putTag();
                        } else {
                          _addTag();
                        }
                      },
                      child: const Text("提交"),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Fluttertoast.showToast(
                            msg: "已取消",
                            gravity: ToastGravity.CENTER,
                          );
                        },
                        child: const Text("取消"))
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
