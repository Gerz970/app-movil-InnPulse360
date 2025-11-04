/*
  Esta clase tiene como objetivo modelar un objeto que sera utilizable a manera de lista
  por el routedador de pantallas, en este se modela las propiedades que toda pantalla debe tener
  se debe tener todas las pantallas registradas mediante este modelo
*/

import 'package:app_movil_innpulse/features/home/home_screen.dart';
import 'package:flutter/material.dart';
import '../features/login/login_screen.dart';
import '../features/login/register_screen.dart';


class RouteItem {
  final String nombre; // Nombre de la ruta
  final String ruta; // Ruta de la pagina
  final Widget screen; // screen de la ruta
  final List<String> permisos; // Permisos de la ruta

  // constructor de la clase RouteItem, se debe inicializar con los valores de la clase
  // ya que si no se inicializa con los valores de la clase, se generara un error de compilacion
  const RouteItem({
    required this.nombre, // nombre de la ruta
    required this.ruta, // ruta de la pagina
    required this.screen, // screen de la ruta
    required this.permisos // permisos de la ruta
  });
}

// lista de rutas de la aplicación
final List<RouteItem> routes = [
  // ruta de login
  RouteItem(
    nombre: 'LoginScreen', // nombre de la ruta
    ruta: '/login', // ruta de la pagina
    screen: LoginScreen(), // screen de la ruta
    permisos: ['*'], // permisos de la ruta, * significa que la ruta es publico
  ),
  RouteItem(
    nombre: 'RegisterScreen', // nombre de la ruta
    ruta: '/register', // ruta de la pagina
    screen: RegisterScreen(), // nombre de la clase de la screen
    permisos: ['*'] // permisos de la ruta, * significa que es publica
  ),
  RouteItem(
    nombre: 'HomeScreen', //nombre de la ruta
    ruta: '/home', // ruta de la pantalla
    screen: HomeScreen(), // clase de la screen
    permisos: ['*'] //permisos de la pantalla, * significa que es publica
  )
];