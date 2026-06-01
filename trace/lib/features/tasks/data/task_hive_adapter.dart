import 'package:hive/hive.dart';

import '../domain/task.dart';
import '../domain/task_priority.dart';
import '../domain/task_status.dart';

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    var id = '';
    var name = '';
    String? description;
    DateTime? startTime;
    var deadline = DateTime.now();
    var project = '';
    var priority = TaskPriority.medium;
    var tags = <String>[];
    var status = TaskStatus.upcoming;
    var createdAt = DateTime.now();
    DateTime? completedAt;
    DateTime? failedAt;

    for (var i = 0; i < fieldCount; i++) {
      switch (reader.readByte()) {
        case 0:
          id = reader.readString();
          break;
        case 1:
          name = reader.readString();
          break;
        case 2:
          description = reader.readBool() ? reader.readString() : null;
          break;
        case 3:
          startTime = reader.readBool() ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null;
          break;
        case 4:
          deadline = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
          break;
        case 5:
          project = reader.readString();
          break;
        case 6:
          priority = TaskPriority.values[reader.readByte()];
          break;
        case 7:
          tags = reader.readStringList();
          break;
        case 8:
          status = TaskStatus.values[reader.readByte()];
          break;
        case 9:
          createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
          break;
        case 10:
          completedAt = reader.readBool() ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null;
          break;
        case 11:
          failedAt = reader.readBool() ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null;
          break;
      }
    }

    return Task(
      id: id,
      name: name,
      description: description,
      startTime: startTime,
      deadline: deadline,
      project: project,
      priority: priority,
      tags: tags,
      status: status,
      createdAt: createdAt,
      completedAt: completedAt,
      failedAt: failedAt,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeByte(12);
    writer.writeByte(0);
    writer.writeString(obj.id);
    writer.writeByte(1);
    writer.writeString(obj.name);
    writer.writeByte(2);
    writer.writeBool(obj.description != null);
    if (obj.description != null) writer.writeString(obj.description!);
    writer.writeByte(3);
    writer.writeBool(obj.startTime != null);
    if (obj.startTime != null) {
      writer.writeInt(obj.startTime!.millisecondsSinceEpoch);
    }
    writer.writeByte(4);
    writer.writeInt(obj.deadline.millisecondsSinceEpoch);
    writer.writeByte(5);
    writer.writeString(obj.project);
    writer.writeByte(6);
    writer.writeByte(obj.priority.index);
    writer.writeByte(7);
    writer.writeStringList(obj.tags);
    writer.writeByte(8);
    writer.writeByte(obj.status.index);
    writer.writeByte(9);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeByte(10);
    writer.writeBool(obj.completedAt != null);
    if (obj.completedAt != null) {
      writer.writeInt(obj.completedAt!.millisecondsSinceEpoch);
    }
    writer.writeByte(11);
    writer.writeBool(obj.failedAt != null);
    if (obj.failedAt != null) {
      writer.writeInt(obj.failedAt!.millisecondsSinceEpoch);
    }
  }
}
