library services;

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:get_storage/get_storage.dart';

export 'package:dio/dio.dart' hide Headers; // export 必须在 part 之前

part 'http.dart';
part 'storage.dart';
part 'event.dart';
