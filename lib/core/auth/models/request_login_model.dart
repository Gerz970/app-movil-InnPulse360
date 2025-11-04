/*
  Este model es para definir la estructura requerida por la API que realiza la autenticacion
*/

class RequestLoginModel {

  // atributos del modelo
  final String login;
  final String password;
  
  // constructor 
  RequestLoginModel({
    // required es para hacer obligatorio el atributo al inicializarse
    required this.login,
    required this.password
  });


  // funcion para retornar objeto a manera de json util para no tener que hacer
  // transformacion en procesos fuera del modelo
  Map<String, dynamic> toJson() {
    return {
      "login": login,
      "password": password
    };
  }
}