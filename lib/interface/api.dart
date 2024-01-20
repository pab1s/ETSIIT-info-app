/// OPENROUTESERVICE DIRECTION SERVICE REQUEST
/// Parameters are : startPoint, endPoint and api key
library;

const String baseUrl = 'https://api.openrouteservice.org/v2/directions/';
const String pathParam = 'driving-car';
const String apiKey =
    '5b3ce3597851110001cf6248ca4d68588eb540bcbbf25891c53ad0f5';

getRouteUrl(String startPoint, String endPoint) {
  return Uri.parse(
      '$baseUrl$pathParam?api_key=$apiKey&start=$startPoint&end=$endPoint');
}
