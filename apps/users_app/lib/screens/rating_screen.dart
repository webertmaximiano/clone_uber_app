import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:users_app/models/ride_request.dart';
import 'package:users_app/models/ride_rating.dart';
import 'package:users_app/services/rating_service.dart';
import 'package:uuid/uuid.dart';

class RatingScreen extends StatefulWidget {
  final RideRequest rideRequest;

  const RatingScreen({
    Key? key,
    required this.rideRequest,
  }) : super(key: key);

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final RatingService _ratingService = RatingService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _commentController = TextEditingController();

  double _rating = 5.0;
  bool _isLoading = false;

  Future<void> _submitRating() async {
    if (rideRequest.driverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Motorista não encontrado'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuário não autenticado');

      final rating = RideRating(
        id: const Uuid().v4(),
        rideId: widget.rideRequest.id,
        userId: userId,
        driverId: widget.rideRequest.driverId!,
        rating: _rating,
        comment: _commentController.text,
        createdAt: DateTime.now(),
      );

      await _ratingService.createRideRating(rating);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avaliação enviada com sucesso!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar avaliação: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliar Corrida'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // Ícone de sucesso
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 48,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),

              // Mensagem de conclusão
              const Text(
                'Corrida Concluída!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Destino: ${widget.rideRequest.destinationAddress}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 32),

              // Informações da corrida
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Distância'),
                          Text('${widget.rideRequest.estimatedDistance.toStringAsFixed(1)} km'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Valor da Corrida'),
                          Text('R\$ ${widget.rideRequest.estimatedFare.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tipo'),
                          Text(
                            widget.rideRequest.rideType == 'economy'
                                ? 'Economy'
                                : widget.rideRequest.rideType == 'comfort'
                                    ? 'Comfort'
                                    : 'Executive',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Avaliação com estrelas
              const Text(
                'Como foi sua experiência?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Estrelas interativas
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(5, (index) {
                    final starRating = index + 1;
                    final isFilled = _rating >= starRating;

                    return GestureDetector(
                      onTap: () => setState(() => _rating = starRating.toDouble()),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(
                          isFilled ? Icons.star : Icons.star_outline,
                          size: 48,
                          color: Colors.amber,
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${_rating.toStringAsFixed(1)} de 5.0',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Comentário
              const Text(
                'Deixe um comentário (opcional)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Conte-nos mais sobre sua experiência...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 32),

              // Botão de enviar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRating,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Enviar Avaliação',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // Pular avaliação
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Pular Avaliação'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  RideRequest get rideRequest => widget.rideRequest;
}
