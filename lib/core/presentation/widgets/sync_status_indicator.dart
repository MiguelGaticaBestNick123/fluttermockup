import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/sync/presentation/bloc/sync_bloc.dart';
import '../../../features/sync/presentation/bloc/sync_state.dart';

class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        if (state is SyncInProgress) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 8),
                Text('Sincronizando...', style: TextStyle(fontSize: 12)),
              ],
            ),
          );
        } else if (state is SyncSuccess) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.cloud_done, color: Colors.greenAccent, size: 20),
                SizedBox(width: 8),
                Text('Sincronizado', style: TextStyle(fontSize: 12)),
              ],
            ),
          );
        } else if (state is SyncFailure) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.cloud_off, color: Colors.orangeAccent, size: 20),
                SizedBox(width: 8),
                Text('Sin conexión', style: TextStyle(fontSize: 12)),
              ],
            ),
          );
        }
        // Default state (e.g. Initial) - assume online or check connectivity if possible
        // For now, we can show a neutral state or nothing
        return const SizedBox.shrink(); 
      },
    );
  }
}
