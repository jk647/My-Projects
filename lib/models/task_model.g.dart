// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 0;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      title: fields[0] as String,
      description: fields[1] as String,
      time: fields[2] as String,
      tag: fields[3] as String,
      isDone: fields[4] as bool,
      isPinned: fields[5] as bool,
      userEmail: fields[6] as String?,
      startDate: fields[7] as DateTime?,
      dueDate: fields[8] as DateTime?,
      estimatedDurationMinutes: fields[11] as int?,
      priority: fields[12] as TaskPriority,
      reminders: (fields[13] as List).cast<String>(),
      repeatType: fields[14] as TaskRepeatType,
      repeatConfig: (fields[15] as Map?)?.cast<String, dynamic>(),
      repeatEndDate: fields[16] as DateTime?,
      subtasks: (fields[17] as List).cast<SubTask>(),
      attachmentPaths: (fields[18] as List).cast<String>(),
      createdAt: fields[19] as DateTime?,
      updatedAt: fields[20] as DateTime?,
    )
      ..startTimeString = fields[9] as String?
      ..dueTimeString = fields[10] as String?;
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.tag)
      ..writeByte(4)
      ..write(obj.isDone)
      ..writeByte(5)
      ..write(obj.isPinned)
      ..writeByte(6)
      ..write(obj.userEmail)
      ..writeByte(7)
      ..write(obj.startDate)
      ..writeByte(8)
      ..write(obj.dueDate)
      ..writeByte(9)
      ..write(obj.startTimeString)
      ..writeByte(10)
      ..write(obj.dueTimeString)
      ..writeByte(11)
      ..write(obj.estimatedDurationMinutes)
      ..writeByte(12)
      ..write(obj.priority)
      ..writeByte(13)
      ..write(obj.reminders)
      ..writeByte(14)
      ..write(obj.repeatType)
      ..writeByte(15)
      ..write(obj.repeatConfig)
      ..writeByte(16)
      ..write(obj.repeatEndDate)
      ..writeByte(17)
      ..write(obj.subtasks)
      ..writeByte(18)
      ..write(obj.attachmentPaths)
      ..writeByte(19)
      ..write(obj.createdAt)
      ..writeByte(20)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubTaskAdapter extends TypeAdapter<SubTask> {
  @override
  final int typeId = 1;

  @override
  SubTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubTask(
      title: fields[0] as String,
      isCompleted: fields[1] as bool,
      order: fields[2] as int,
      createdAt: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SubTask obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.isCompleted)
      ..writeByte(2)
      ..write(obj.order)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskPriorityAdapter extends TypeAdapter<TaskPriority> {
  @override
  final int typeId = 2;

  @override
  TaskPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskPriority.low;
      case 1:
        return TaskPriority.medium;
      case 2:
        return TaskPriority.high;
      case 3:
        return TaskPriority.critical;
      default:
        return TaskPriority.medium;
    }
  }

  @override
  void write(BinaryWriter writer, TaskPriority obj) {
    switch (obj) {
      case TaskPriority.low:
        writer.writeByte(0);
        break;
      case TaskPriority.medium:
        writer.writeByte(1);
        break;
      case TaskPriority.high:
        writer.writeByte(2);
        break;
      case TaskPriority.critical:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskRepeatTypeAdapter extends TypeAdapter<TaskRepeatType> {
  @override
  final int typeId = 3;

  @override
  TaskRepeatType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskRepeatType.none;
      case 1:
        return TaskRepeatType.daily;
      case 2:
        return TaskRepeatType.weekly;
      case 3:
        return TaskRepeatType.monthly;
      case 4:
        return TaskRepeatType.custom;
      default:
        return TaskRepeatType.none;
    }
  }

  @override
  void write(BinaryWriter writer, TaskRepeatType obj) {
    switch (obj) {
      case TaskRepeatType.none:
        writer.writeByte(0);
        break;
      case TaskRepeatType.daily:
        writer.writeByte(1);
        break;
      case TaskRepeatType.weekly:
        writer.writeByte(2);
        break;
      case TaskRepeatType.monthly:
        writer.writeByte(3);
        break;
      case TaskRepeatType.custom:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskRepeatTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
