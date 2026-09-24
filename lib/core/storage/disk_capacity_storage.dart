import 'package:disk_capacity/disk_capacity.dart';

import 'storage_capacity.dart';

class DiskCapacityStorage implements StorageCapacity {
  DiskCapacityStorage({DiskCapacity? diskCapacity})
    : _diskCapacity = diskCapacity ?? DiskCapacity();

  final DiskCapacity _diskCapacity;

  @override
  Future<int?> freeBytesFor(String path) async {
    final megabytes = await _diskCapacity.getFreeDiskSpaceForPath(path);
    if (!megabytes.isFinite || megabytes < 0) return null;
    return (megabytes * 1024 * 1024).floor();
  }
}
