import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Channel local notifications
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Inicializar notificações
  Future<void> initialize() async {
    try {
      // Solicitar permissão
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carryForward: true,
        criticalAlert: true,
        provisional: true,
        sound: true,
      );

      if (kDebugMode) {
        print(
            'Notificações permissão: ${settings.authorizationStatus.toString()}');
      }

      // Configurar handlers
      _setupMessageHandlers();

      // Inicializar local notifications
      _initializeLocalNotifications();

      // Obter e salvar token
      await _saveFCMToken();

      // Escutar mudanças de token
      _firebaseMessaging.onTokenRefresh.listen(_saveFCMTokenFromStream);
    } catch (e) {
      if (kDebugMode) print('Erro ao inicializar notificações: $e');
    }
  }

  // Configurar handlers de mensagem
  void _setupMessageHandlers() {
    // Mensagens quando app está em foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Notificação em foreground:');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
        print('Data: ${message.data}');
      }

      // Mostrar notificação local
      _showLocalNotification(message);

      // Processar dados
      _handleNotificationData(message.data);
    });

    // Quando app é aberto via notificação
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Notificação clicada:');
        print('Title: ${message.notification?.title}');
      }

      _handleNotificationData(message.data);
    });
  }

  // Inicializar notificações locais
  void _initializeLocalNotifications() {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) {
        if (kDebugMode) print('Local notification tapped: $title');
      },
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (kDebugMode) print('Local notification response: ${response.payload}');
      },
    );
  }

  // Salvar FCM token no Firestore
  Future<void> _saveFCMToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': DateTime.now(),
        });

        if (kDebugMode) print('FCM Token salvo: $token');
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao salvar FCM token: $e');
    }
  }

  // Listener para atualizações de token
  void _saveFCMTokenFromStream(String token) {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': DateTime.now(),
        });

        if (kDebugMode) print('FCM Token atualizado: $token');
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao atualizar FCM token: $e');
    }
  }

  // Mostrar notificação local
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'ride_notifications',
      'Notificações de Corridas',
      channelDescription: 'Notificações de atualizações de corridas',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
      styleInformation: const BigTextStyleInformation(''),
    );

    final DarwinNotificationDetails iosDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformDetails,
      payload: message.data.isEmpty ? null : message.data.toString(),
    );
  }

  // Processar dados da notificação
  void _handleNotificationData(Map<String, dynamic> data) {
    try {
      final type = data['type'];
      final rideId = data['rideId'];

      if (kDebugMode) {
        print('Processando notificação: type=$type, rideId=$rideId');
      }

      // Aqui você pode acionar ações específicas
      // como atualizar a UI ou navegar para uma tela
      switch (type) {
        case 'ride_assigned':
          // Motorista foi atribuído
          _onRideAssigned(rideId);
          break;
        case 'ride_started':
          // Corrida iniciou
          _onRideStarted(rideId);
          break;
        case 'ride_completed':
          // Corrida foi completa
          _onRideCompleted(rideId);
          break;
        case 'driver_arrived':
          // Motorista chegou
          _onDriverArrived(rideId);
          break;
        default:
          break;
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao processar dados da notificação: $e');
    }
  }

  // Callbacks para diferentes tipos de notificação
  void _onRideAssigned(String? rideId) {
    if (kDebugMode) print('Motorista atribuído à corrida: $rideId');
    // Aqui você pode:
    // - Atualizar UI
    // - Reproduzir som
    // - Enviar para analytics
    // - Atualizar cache local
  }

  void _onRideStarted(String? rideId) {
    if (kDebugMode) print('Corrida iniciou: $rideId');
    // Transição automática para RideTrackingScreen
    // Iniciar atualização de localização em tempo real
  }

  void _onRideCompleted(String? rideId) {
    if (kDebugMode) print('Corrida completada: $rideId');
    // Notificar usuário que pode avaliar
    // Preparar dados para RatingScreen
    // Limpar dados de rastreamento
  }

  void _onDriverArrived(String? rideId) {
    if (kDebugMode) print('Motorista chegou: $rideId');
    // Mostrar alerta visual
    // Destacar notificação
    // Permitir iniciar corrida
  }

  // Enviar notificação para outro usuário via Firestore
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    required Map<String, String> data,
  }) async {
    try {
      // Obter FCM token do usuário
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final fcmToken = userDoc.data()?['fcmToken'] as String?;

      if (fcmToken == null) {
        if (kDebugMode) print('FCM token não encontrado para usuário: $userId');
        return;
      }

      // Enviar via Cloud Functions (você implementará)
      // Por enquanto, apenas registramos
      if (kDebugMode) {
        print('Notificação agendada para $userId');
        print('Token: $fcmToken');
        print('Título: $title');
        print('Corpo: $body');
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao enviar notificação: $e');
    }
  }

  // Deletar token ao fazer logout
  Future<void> deleteToken() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': FieldValue.delete(),
        });

        await _firebaseMessaging.deleteToken();
        if (kDebugMode) print('FCM Token deletado');
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao deletar FCM token: $e');
    }
  }
}
