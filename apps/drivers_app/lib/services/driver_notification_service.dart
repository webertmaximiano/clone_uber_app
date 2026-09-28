import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class DriverNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
            'Notificações driver permissão: ${settings.authorizationStatus.toString()}');
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
      if (kDebugMode) print('Erro ao inicializar notificações driver: $e');
    }
  }

  // Configurar handlers de mensagem
  void _setupMessageHandlers() {
    // Mensagens quando app está em foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Driver - Notificação em foreground:');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
        print('Data: ${message.data}');
      }

      // Mostrar notificação local com som e vibração
      _showLocalNotification(message);

      // Processar dados
      _handleNotificationData(message.data);
    });

    // Quando app é aberto via notificação
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Driver - Notificação clicada:');
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
        if (kDebugMode) print('Driver - Local notification: $title');
      },
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (kDebugMode) print('Driver - Resposta notificação: ${response.payload}');
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
        await _firestore.collection('drivers').doc(user.uid).update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': DateTime.now(),
        });

        if (kDebugMode) print('Driver - FCM Token salvo: $token');
      }
    } catch (e) {
      if (kDebugMode) print('Driver - Erro ao salvar FCM token: $e');
    }
  }

  // Listener para atualizações de token
  void _saveFCMTokenFromStream(String token) {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        _firestore.collection('drivers').doc(user.uid).update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': DateTime.now(),
        });

        if (kDebugMode) print('Driver - FCM Token atualizado: $token');
      }
    } catch (e) {
      if (kDebugMode) print('Driver - Erro ao atualizar FCM token: $e');
    }
  }

  // Mostrar notificação local (com som de alerta para novas corridas)
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final isNewRide = message.data['type'] == 'new_ride_available';

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'driver_notifications',
      'Notificações de Corridas',
      channelDescription:
          'Notificações de novas corridas disponíveis e atualizações',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
      sound: isNewRide ? const RawResourceAndroidNotificationSound('alert') : null,
      styleInformation: const BigTextStyleInformation(''),
    );

    final DarwinNotificationDetails iosDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: isNewRide ? 'default' : null,
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
        print('Driver - Processando notificação: type=$type, rideId=$rideId');
      }

      switch (type) {
        case 'new_ride_available':
          // Nova corrida disponível próxima
          _onNewRideAvailable(rideId);
          break;
        case 'ride_accepted':
          // Corrida foi aceita (pode ser por outro motorista)
          _onRideAccepted(rideId);
          break;
        case 'user_cancelled':
          // Usuário cancelou a corrida
          _onUserCancelled(rideId);
          break;
        default:
          break;
      }
    } catch (e) {
      if (kDebugMode) print('Driver - Erro ao processar notificação: $e');
    }
  }

  // Callbacks para diferentes tipos de notificação
  void _onNewRideAvailable(String? rideId) {
    if (kDebugMode) print('Driver - Nova corrida disponível: $rideId');
    // Abrir AvailableRidesScreen automaticamente
    // Destacar corrida na lista
  }

  void _onRideAccepted(String? rideId) {
    if (kDebugMode) print('Driver - Corrida aceita (pode ser outro motorista): $rideId');
    // Remover da lista de disponíveis
    // Limpar notificação
  }

  void _onUserCancelled(String? rideId) {
    if (kDebugMode) print('Driver - Usuário cancelou corrida: $rideId');
    // Notificar e remover da lista
    // Restaurar disponibilidade
  }

  // Método público para mostrar notificação local (usado pelo RideListenerService)
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
    bool playSound = true,
    bool useAlertSound = false,
    bool enableVibration = true,
  }) async {
    try {
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'driver_notifications',
        'Notificações de Corridas',
        channelDescription: 'Notificações de novas corridas disponíveis',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: enableVibration,
        playSound: playSound,
        sound: useAlertSound ? const RawResourceAndroidNotificationSound('alert') : null,
        styleInformation: const BigTextStyleInformation(''),
      );

      final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: playSound,
        sound: useAlertSound ? 'default' : null,
      );

      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id,
        title,
        body,
        platformDetails,
        payload: payload != null ? payload.toString() : null,
      );

      if (kDebugMode) print('Driver - Notificação local exibida: $title');
    } catch (e) {
      if (kDebugMode) print('Driver - Erro ao exibir notificação local: $e');
    }
  }

  // Deletar token ao fazer logout
  Future<void> deleteToken() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('drivers').doc(user.uid).update({
          'fcmToken': FieldValue.delete(),
        });

        await _firebaseMessaging.deleteToken();
        if (kDebugMode) print('Driver - FCM Token deletado');
      }
    } catch (e) {
      if (kDebugMode) print('Driver - Erro ao deletar FCM token: $e');
    }
  }
}
