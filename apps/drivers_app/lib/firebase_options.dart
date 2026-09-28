import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDQmPJx_YwFhRj8qKlJ2xPqWYqVm0Lz8Qw',
    appId: '1:123456789:web:abcdefg1234567',
    messagingSenderId: '123456789',
    projectId: 'clone-uber-app-c21a1',
    authDomain: 'clone-uber-app-c21a1.firebaseapp.com',
    databaseURL: 'https://clone-uber-app-c21a1.firebaseio.com',
    storageBucket: 'clone-uber-app-c21a1.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDQmPJx_YwFhRj8qKlJ2xPqWYqVm0Lz8Qw',
    appId: '1:123456789:android:abcdefg1234567',
    messagingSenderId: '123456789',
    projectId: 'clone-uber-app-c21a1',
    storageBucket: 'clone-uber-app-c21a1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDQmPJx_YwFhRj8qKlJ2xPqWYqVm0Lz8Qw',
    appId: '1:123456789:ios:abcdefg1234567',
    messagingSenderId: '123456789',
    projectId: 'clone-uber-app-c21a1',
    storageBucket: 'clone-uber-app-c21a1.appspot.com',
    iosBundleId: 'com.vitorcf22.cloneUberApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDQmPJx_YwFhRj8qKlJ2xPqWYqVm0Lz8Qw',
    appId: '1:123456789:macos:abcdefg1234567',
    messagingSenderId: '123456789',
    projectId: 'clone-uber-app-c21a1',
    storageBucket: 'clone-uber-app-c21a1.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDQmPJx_YwFhRj8qKlJ2xPqWYqVm0Lz8Qw',
    appId: '1:123456789:windows:abcdefg1234567',
    messagingSenderId: '123456789',
    projectId: 'clone-uber-app-c21a1',
    storageBucket: 'clone-uber-app-c21a1.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDQmPJx_YwFhRj8qKlJ2xPqWYqVm0Lz8Qw',
    appId: '1:123456789:linux:abcdefg1234567',
    messagingSenderId: '123456789',
    projectId: 'clone-uber-app-c21a1',
    storageBucket: 'clone-uber-app-c21a1.appspot.com',
  );
}
