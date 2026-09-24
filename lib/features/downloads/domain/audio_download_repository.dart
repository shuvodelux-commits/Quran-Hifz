import 'download_job.dart';

abstract class AudioDownloadRepository {
  Future<DownloadJob?> getJob(String audioKey);
  Future<List<DownloadJob>> listJobs();
  Future<DownloadJob> enqueue(AudioDownloadRequest request);
  Future<DownloadJob> download(String audioKey);
  Future<void> pause(String audioKey);
  Future<DownloadJob> resume(String audioKey);
  Future<DownloadJob> retry(String audioKey);
  Future<void> cancel(String audioKey);
  Future<void> delete(String audioKey);
}
