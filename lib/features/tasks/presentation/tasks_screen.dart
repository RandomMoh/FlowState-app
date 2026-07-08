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
        title: Text(
          'TASKS',
          style: TextStyle(letterSpacing: 4.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: context.colors.background,
        elevation: 0,
        actions: [
          if (completed.isNotEmpty)
            TextButton(
              onPressed: () {
                for (final t in completed) {
                  ref.read(tasksProvider.notifier).deleteTask(t.id);
                }
              },
              child: Text(
                'CLEAR DONE',
                style: TextStyle(
                    color: context.colors.textSecondary,
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
                final tile = _TaskTile(
                  task: task,
                  index: index,
                  onToggle: () =>
                      ref.read(tasksProvider.notifier).toggleTask(task.id),
                  onEdit: () => _showTaskDialog(existingTask: task),
                  onDelete: () =>
                      ref.read(tasksProvider.notifier).deleteTask(task.id),
                )
                .animate()
                .fadeIn(delay: (50 * index).ms)
                .slideX(begin: 0.1);

                return KeyedSubtree(
                  key: ValueKey(task.id),
                  child: tile,
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskDialog(),
        backgroundColor: context.colors.primaryAccent,
        foregroundColor: context.colors.background,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        icon: Icon(Icons.add),
        label: Text('ADD TASK',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline,
              size: 64, color: context.colors.textSecondary),
          SizedBox(height: 16),
          Text(
            'NO TASKS YET',
            style: TextStyle(
              color: context.colors.textSecondary,
              letterSpacing: 3.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap + to add your first task',
            style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
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
        child: Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border.all(
            color: task.isCompleted
                ? context.colors.muted.withValues(alpha: 0.3)
                : context.colors.muted.withValues(alpha: 0.5),
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
                    ? context.colors.primaryAccent
                    : Colors.transparent,
                border: Border.all(
                  color: task.isCompleted
                      ? context.colors.primaryAccent
                      : context.colors.textSecondary,
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? Icon(Icons.check,
                      size: 14, color: context.colors.background)
                  : null,
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              color: task.isCompleted
                  ? context.colors.textSecondary
                  : context.colors.textPrimary,
              decoration:
                  task.isCompleted ? TextDecoration.lineThrough : null,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            task.project,
            style: TextStyle(
                color: context.colors.textSecondary, fontSize: 12),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit button
              IconButton(
                icon: Icon(Icons.edit_outlined,
                    color: context.colors.textSecondary, size: 18),
                onPressed: onEdit,
                tooltip: 'Edit',
              ),
              // Drag handle
              ReorderableDragStartListener(
                index: index,
                child: Icon(Icons.drag_handle,
                    color: context.colors.textSecondary),
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
      backgroundColor: context.colors.surface2,
      title: Text(
        isEditing ? 'EDIT TASK' : 'NEW TASK',
        style: TextStyle(
          color: context.colors.textPrimary,
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
          child: Text(
            'CANCEL',
            style: TextStyle(color: context.colors.textSecondary),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.primaryAccent,
            foregroundColor: context.colors.background,
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
            style: TextStyle(fontWeight: FontWeight.w800),
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
      style: TextStyle(color: context.colors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: context.colors.textSecondary),
        filled: true,
        fillColor: context.colors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: context.colors.muted),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: context.colors.muted),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide:
              BorderSide(color: context.colors.primaryAccent, width: 2),
        ),
      ),
    );
  }
}
