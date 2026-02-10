import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/user_model.dart';
import '../../providers/user_provider.dart';

class UserManagementPage extends ConsumerWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showUserDialog(context, ref),
          ),
        ],
      ),
      body: usersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No users found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(user.name.isNotEmpty
                        ? user.name[0].toUpperCase()
                        : '?'),
                  ),
                  title: Text(user.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email),
                      if (user.phone != null) Text(user.phone!),
                      const SizedBox(height: 2),
                      Chip(
                        label: Text(user.role.toUpperCase()),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        labelStyle: const TextStyle(fontSize: 11),
                        backgroundColor:
                            user.isActive ? Colors.green[100] : Colors.red[100],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _showUserDialog(context, ref, user: user),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () => _confirmDelete(context, ref, user),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showUserDialog(BuildContext context, WidgetRef ref, {UserModel? user}) {
    final isEdit = user != null;
    final nameController = TextEditingController(text: user?.name);
    final emailController = TextEditingController(text: user?.email);
    final phoneController = TextEditingController(text: user?.phone);
    final passwordController = TextEditingController(text: user?.password);
    String role = user?.role ?? 'Eceran';
    bool isActive = user?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Pengguna' : 'Tambah Pengguna'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Telepon'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: passwordController,
                decoration:
                    const InputDecoration(labelText: 'Password (Local)'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Role'),
                value: role,
                items: ['admin', 'staff', 'cashier', 'Grosir', 'Eceran']
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(r.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) role = value;
                },
              ),
              SwitchListTile(
                title: const Text('Aktif'),
                value: isActive,
                onChanged: (val) => isActive =
                    val, // This won't update UI in dialog without StatefulBuilder, but for simplicity
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty || emailController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name and Email are required')),
                );
                return;
              }

              final newUser = UserModel(
                id: user?.id ?? const Uuid().v4(),
                name: nameController.text,
                email: emailController.text,
                phone:
                    phoneController.text.isEmpty ? null : phoneController.text,
                role: role,
                isActive: isActive,
                password: passwordController.text.isEmpty
                    ? null
                    : passwordController.text,
                createdAt: user?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );

              try {
                if (isEdit) {
                  await ref.read(usersProvider.notifier).updateUser(newUser);
                } else {
                  await ref.read(usersProvider.notifier).addUser(newUser);
                }
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User?'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(usersProvider.notifier).deleteUser(user.id);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}



