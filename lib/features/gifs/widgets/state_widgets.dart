import 'package:flutter/material.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Nenhum GIF encontrado 😕', style: TextStyle(fontSize: 16)),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String message;

  const ErrorState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Erro: $message',
        style: const TextStyle(color: Colors.red, fontSize: 16),
      ),
    );
  }
}
