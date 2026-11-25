// lib/pages/{feature_name}/index.dart
//
// 模块唯一 import 入口。新增成员文件时必须同步补 part 声明。
library pages.user_profile;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:your_project/routes/index.dart';
import 'package:your_project/widgets/index.dart';

part 'controller.dart';
part 'view.dart';
// part 'widgets/profile_header.dart';   // 子目录里写 part of '../index.dart';
// part 'dialog/confirm_dialog.dart';
