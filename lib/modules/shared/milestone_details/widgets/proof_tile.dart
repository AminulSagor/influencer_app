import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';

bool _isImagePath(String s) {
  final lower = s.toLowerCase().trim();

  final clean = lower.split('?').first.split('#').first;

  final imageExtPattern = RegExp(
    r'\.(jpg|jpeg|png|webp|gif)(-\d+)?$',
    caseSensitive: false,
  );

  return imageExtPattern.hasMatch(clean);
}

class ProofTile extends StatelessWidget {
  final String? networkUrl; // remote
  final File? localFile; // local
  final double height;

  const ProofTile({
    super.key,
    this.networkUrl,
    this.localFile,
    this.height = 110,
  });

  bool get _isNetwork => (networkUrl ?? '').trim().isNotEmpty;
  bool get _isLocal => localFile != null;

  String get _sourcePath => _isLocal ? localFile!.path : (networkUrl ?? '');

  bool get _isImage => _isImagePath(_sourcePath);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: _isImage ? _buildImage(context) : _buildDownload(context),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final image = _isLocal
        ? Image.file(
            localFile!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          )
        : Image.network(
            networkUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              _FullScreenImage(networkUrl: networkUrl, localFile: localFile),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Tap to view',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownload(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          if (_isLocal) {
            await OpenFilex.open(localFile!.path);
            return;
          }

          final url = (networkUrl ?? '').trim();
          if (url.isEmpty) return;

          final dir = await getApplicationDocumentsDirectory();
          final fileName = p.basename(Uri.parse(url).path);
          final savePath = p.join(
            dir.path,
            fileName.isEmpty ? 'proof_file' : fileName,
          );

          await Dio().download(url, savePath);
          await OpenFilex.open(savePath);
        },
        child: const Text('Download'),
      ),
    );
  }
}

class _FullScreenImage extends StatelessWidget {
  final String? networkUrl;
  final File? localFile;

  const _FullScreenImage({this.networkUrl, this.localFile});

  @override
  Widget build(BuildContext context) {
    final provider = localFile != null
        ? FileImage(localFile!)
        : NetworkImage(networkUrl!) as ImageProvider;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: PhotoView(
        imageProvider: provider,
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
      ),
    );
  }
}
