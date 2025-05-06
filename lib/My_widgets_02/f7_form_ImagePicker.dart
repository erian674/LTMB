import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import "package:image_picker/image_picker.dart";

class FormBasicDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FormBasicDemoSate();
}

class _FormBasicDemoSate extends State<FormBasicDemo> {
  // Sử dụng Global key để truy cập form
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool _obscurePassword = true;
  String? _name;
  String? _selectedCity;
  String? _gender;
  bool _isAgreed = false;
  DateTime? _selectedDate;
  File? _profileImage;

  final List<String> _cities = [
    'Hà Nội',
    'TP.HCM',
    'Đà Nẵng',
    'Cần Thơ',
    'Hải Phòng',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Form cơ bản")),

      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fullnameController,
                decoration: InputDecoration(
                  labelText: "Họ và tên",
                  hintText: "Nhập họ và tên của bạn",
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) {
                  _name = value;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              FormField<File>(
                validator: (value) {
                  if (value == null) {
                    return 'Vui lòng chọn ảnh đại diện';
                  }
                  return null;
                },
                builder: (FormFieldState<File> state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ảnh đại diện',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            final XFile? image = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Chọn nguồn'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.photo_library),
                                      title: Text('Thư viện'),
                                      onTap: () async {
                                        Navigator.pop(
                                          context,
                                          await _picker.pickImage(
                                            source: ImageSource.gallery,
                                          ),
                                        );
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.camera_alt),
                                      title: Text('Máy ảnh'),
                                      onTap: () async {
                                        Navigator.pop(
                                          context,
                                          await _picker.pickImage(
                                            source: ImageSource.camera,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );

                            if (image != null) {
                              setState(() {
                                _profileImage = File(image.path);
                                state.didChange(_profileImage);
                              });
                            }
                          },
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(60),
                              border: Border.all(
                                color: state.hasError ? Colors.red : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: _profileImage != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Image.file(
                                _profileImage!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            )
                                : Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                      if (state.hasError)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              state.errorText!,
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Xin chào $_name")),
                        );
                      }
                    },
                    child: Text("Submit"),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                      setState(() {
                        _name = null;
                      });
                    },
                    child: Text("Reset"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
