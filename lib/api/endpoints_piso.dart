class EndpointsPiso {
  static const String pisos = "pisos";

  static detail(int pisoId) => "pisos/$pisoId";
  static String getByHotel(int hotelId) => "pisos/get-by-hotel/$hotelId";

}
