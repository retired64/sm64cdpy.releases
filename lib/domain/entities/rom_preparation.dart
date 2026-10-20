enum RomPreparationPhase {
  idle,
  picking,
  inspecting,
  converting,
  validating,
  prepared,
  choosingDestination,
  exporting,
  verifyingExport,
  saved,
  cancelling,
  cancelled,
  failed;

  bool get busy => switch (this) {
    picking ||
    inspecting ||
    converting ||
    validating ||
    choosingDestination ||
    exporting ||
    verifyingExport ||
    cancelling => true,
    _ => false,
  };
}

class RomPreparationState {
  const RomPreparationState({
    this.phase = RomPreparationPhase.idle,
    this.operationId,
    this.revision = 0,
    this.inputName,
    this.outputName,
    this.sourceFormat,
    this.processedBytes,
    this.totalBytes,
    this.errorCode,
    this.technicalDetail,
    this.canExport = false,
    this.initialized = false,
  });

  factory RomPreparationState.fromMap(Map<Object?, Object?> value) {
    final phaseName = value['phase'] as String? ?? 'idle';
    return RomPreparationState(
      phase: RomPreparationPhase.values.firstWhere(
        (phase) => phase.name == phaseName,
        orElse: () => RomPreparationPhase.failed,
      ),
      operationId: value['operationId'] as String?,
      revision: (value['revision'] as num?)?.toInt() ?? 0,
      inputName: value['inputName'] as String?,
      outputName: value['outputName'] as String?,
      sourceFormat: value['sourceFormat'] as String?,
      processedBytes: (value['processedBytes'] as num?)?.toInt(),
      totalBytes: (value['totalBytes'] as num?)?.toInt(),
      errorCode: value['errorCode'] as String?,
      technicalDetail: value['technicalDetail'] as String?,
      canExport: value['canExport'] == true,
      initialized: true,
    );
  }

  final RomPreparationPhase phase;
  final String? operationId;
  final int revision;
  final String? inputName;
  final String? outputName;
  final String? sourceFormat;
  final int? processedBytes;
  final int? totalBytes;
  final String? errorCode;
  final String? technicalDetail;
  final bool canExport;
  final bool initialized;

  double? get progress {
    final total = totalBytes;
    final processed = processedBytes;
    if (total == null || total <= 0 || processed == null) return null;
    return (processed / total).clamp(0, 1);
  }
}
