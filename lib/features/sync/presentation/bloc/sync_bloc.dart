import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/sync_repository.dart';
import 'sync_event.dart';
import 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncRepository syncRepository;

  SyncBloc({required this.syncRepository}) : super(SyncInitial()) {
    on<SyncStarted>(_onSyncStarted);
  }

  Future<void> _onSyncStarted(SyncStarted event, Emitter<SyncState> emit) async {
    emit(SyncInProgress());
    try {
      await syncRepository.syncPendingItems();
      emit(SyncSuccess());
    } catch (e) {
      emit(SyncFailure(e.toString()));
    }
  }
}
