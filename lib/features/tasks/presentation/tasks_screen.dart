import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme.dart';
import '../data/tasks_provider.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {

  Future<void> _showTaskDialog({Task? existingTask}) async {
    await showDialog<void>(
      context: context,
      // Use a proper StatefulWidget so controllers are disposed in its own
      // dispose() — not after showDialog returns (which crashes during animation)
      builder: (ctx) => _TaskDialog(
        existingTask: existingTask,
        onSave: (title, project) {
          if (existingTask != null) {
            ref.read(tasksProvider.notifier).editTask(existingTask.id, title, project);
          } else {
            ref.read(tasksProvider.notifier).addTask(title, project);
          }
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);
    final completed = tasks.where((t) => t.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TASKS',
          style: TextStyle(letterSpacing: 4.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: AppTheme.background,
        elevation: 0,
        actions: [
          if (completed.isNotEmpty)
            TextButton(
              onPressed: () {
                for (final t in completed) {
                  ref.read(tasksProvider.notifier).deleteTask(t.id);
                }
              },
              child: const Text(
                'CLEAR DONE',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    letterSpacing: 1.5),
              ),
            ),
        ],
      ),
      body: tasks.isEmpty
          ? _buildEmpty()
          : ReorderableListView.builder(
              padding: const EdgeInsets.only(
                  left: AppTheme.spacingMd,
                  right: AppTheme.spacingMd,
                  top: AppTheme.spacingMd,
                  bottom: 100),
              buildDefaultDragHandles: false,
              onReorderItem: (oldIndex, newIndex) {
                ref
                    .read(tasksProvider.notifier)
                    .reorderTasks(oldIndex, newIndex);
              },
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _TaskTile(
                  task: task,
                  index: index,
                  onToggle: () =>
                      ref.read(tasksProvider.notifier).toggleTask(task.id),
                  onEdit: () => _showTaskDialog(existingTask: task),
                  onDelete: () =>
                      ref.read(tasksProvider.notifier).deleteTask(task.id),
                )
                .animate(key: ValueKey(task.id))
                .fadeIn(delay: (50 * index).ms)
                .slideX(begin: 0.1);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskDialog(),
        backgroundColor: AppTheme.primaryAccent,
        foregroundColor: AppTheme.background,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        icon: const Icon(Icons.add),
        label: const Text('ADD TASK',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline,
              size: 64, color: AppTheme.textSecondary),
          SizedBox(height: 16),
          Text(
            'NO TASKS YET',
            style: TextStyle(
              color: AppTheme.textSecondary,
              letterSpacing: 3.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap + to add your first task',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}


class _TaskTile extends StatelessWidget {
  final Task task;
  final int index;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskTile({
    super.key,
    required this.task,
    required this.index,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('dismiss_${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red.shade900,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(
            color: task.isCompleted
                ? AppTheme.muted.withValues(alpha: 0.3)
                : AppTheme.muted.withValues(alpha: 0.5),
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          // Checkbox
          leading: GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isCompleted
                    ? AppTheme.primaryAccent
                    : Colors.transparent,
                border: Border.all(
                  color: task.isCompleted
                      ? AppTheme.primaryAccent
                      : AppTheme.textSecondary,
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check,
                      size: 14, color: AppTheme.background)
                  : null,
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              color: task.isCompleted
                  ? AppTheme.textSecondary
                  : AppTheme.textPrimary,
              decoration:
                  task.isCompleted ? TextDecoration.lineThrough : null,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            task.project,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit button
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppTheme.textSecondary, size: 18),
                onPressed: onEdit,
                tooltip: 'Edit',
              ),
              // Drag handle
              ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle,
                    color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _TaskDialog extends StatefulWidget {
  const _TaskDialog({
    required this.onSave,
    this.existingTask,
  });

  final Task? existingTask;
  final void Function(String title, String project) onSave;

  @override
  State<_TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<_TaskDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _projectCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existingTask?.title ?? '');
    _projectCtrl =
        TextEditingController(text: widget.existingTask?.project ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _projectCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTask != null;

    return AlertDialog(
      backgroundColor: AppTheme.surface2,
      title: Text(
        isEditing ? 'EDIT TASK' : 'NEW TASK',
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 13,
          letterSpacing: 3.0,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildField(_titleCtrl, 'Task name'),
          const SizedBox(height: 12),
          _buildField(_projectCtrl, 'Project / label'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'CANCEL',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryAccent,
            foregroundColor: AppTheme.background,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero),
          ),
          onPressed: () {
            final title = _titleCtrl.text.trim();
            if (title.isEmpty) return;
            final project = _projectCtrl.text.trim().isEmpty
                ? 'General'
                : _projectCtrl.text.trim();
            widget.onSave(title, project);
            Navigator.pop(context);
          },
          child: Text(
            isEditing ? 'SAVE' : 'ADD',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      autofocus: ctrl == _titleCtrl,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary),
        filled: true,
        fillColor: AppTheme.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppTheme.muted),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppTheme.muted),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide:
              BorderSide(color: AppTheme.primaryAccent, width: 2),
        ),
      ),
    );
  }
}
