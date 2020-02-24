import 'dart:convert';

final String jsonData =
    '{"2I":["STO/GEO","ITA","STO/GEO","FIS","LAT","","REL","ITA","INGL","LAT","ITA","","FIS","MATE","MATE","INGL","STO/GEO","","SCI","LAT","ITA","MATE","SCI","","INGL","MOT","ARTE","MATE","MATE","","","MOT","","ARTE","",""],"5E":["ARTE","FIS","LAT","LAT","ARTE","MATE","MATE","INGL","ITA","FIS","INGL","MATE","FILO","SCI","MOT","ITA","ITA","LAT","INGL","REL","MOT","ITA","SCI","FILO","STO","FILO","STO","SCI","MATE","FIS","","","","","",""],"5C":["SCI","ARTE","MATE","MOT","INGL","FIS","STO","REL","MATE","MOT","STO","INGL","ARTE","FIS","FIS","INGL","SCI","FILO","ITA","SCI","SCI","MATE","FILO","SCI","ITA","MATE","ITA","ITA","INFO","INFO","","","","","",""],"4D":["ITA","MATE","ARTE","FILO","FILO","SCI","LAT","SCI","ITA","INGL","FIS","FIS","MOT","LAT","ITA","LAT","STO","ARTE","MOT","INGL","MATE","REL","FIS","MATE","FILO","STO","MATE","SCI","ITA","INGL","","","","","",""],"2L":["ARTE","FIS","STO/GEO","MATE","ITA","","ITA","ARTE","SCI","MATE","MATE","","ITA","INGL","MATE","SCI","INFO","","SCI","STO/GEO","REL","ITA","INGL","","INFO","SCI","INGL","FIS","MOT","","","","","STO/GEO","MOT",""],"2M":["MATE","STO/GEO","STO/GEO","INGL","INGL","ARTE","INFO","ITA","ARTE","SCI","SCI","FIS","MOT","REL","INGL","INFO","MATE","ITA","MOT","SCI","SCI","FIS","STO/GEO","ITA","","MATE","ITA","MATE","","","","","","","",""],"2F":["ITA","SCI","STO/GEO","STO/GEO","ARTE","MATE","ITA","INFO","MATE","ITA","STO/GEO","INFO","INGL","ARTE","SCI","MOT","SCI","FIS","SCI","MATE","INGL","MOT","INGL","ITA","REL","MATE","FIS","","","","","","","","",""],"2B":["SCI","STO/GEO","SCI","FIS","MOT","STO/GEO","INGL","ITA","LAT","INGL","MOT","ITA","REL","ARTE","ITA","MATE","FIS","MATE","MATE","LAT","ITA","MATE","STO/GEO","INGL","","MATE","","ARTE","LAT","","","","","","",""],"5F":["INFO","ITA","MATE","MATE","SCI","SCI","ARTE","ITA","MATE","FIS","ARTE","FIS","MATE","SCI","STO","SCI","ITA","STO","INGL","REL","ITA","INFO","FIS","INGL","SCI","FILO","FILO","MOT","INGL","","","","","MOT","",""],"5D":["STO","ITA","MATE","INGL","SCI","MATE","ARTE","ITA","FIS","FIS","SCI","ARTE","FILO","INGL","ITA","SCI","MOT","FIS","INFO","FILO","INFO","MATE","MOT","INGL","SCI","SCI","REL","MATE","STO","ITA","","","","","",""],"3A":["INGL","SCI","LAT","FILO","ARTE","FIS","ITA","INGL","STO","ITA","SCI","MATE","LAT","FILO","FILO","FIS","ITA","MATE","ARTE","MATE","REL","SCI","ITA","STO","FIS","LAT","INGL","MOT","MATE","","","","","MOT","",""],"1C":["STO/GEO","SCI","INGL","SCI","INGL","MOT","SCI","MATE","STO/GEO","INGL","FIS","MOT","MATE","ITA","INFO","ITA","REL","INFO","ARTE","ITA","ARTE","FIS","MATE","MATE","ITA","","MATE","STO/GEO","","","","","","","",""],"2A":["REL","ARTE","MOT","ARTE","MATE","STO/GEO","MATE","INGL","MOT","LAT","FIS","LAT","ITA","FIS","SCI","STO/GEO","INGL","MATE","LAT","SCI","MATE","ITA","STO/GEO","INGL","","","MATE","ITA","ITA","","","","","","",""],"3H":["REL","FIS","INGL","ITA","FIS","MATE","FILO","MATE","SCI","LAT","SCI","INGL","MATE","MOT","STO","SCI","ARTE","STO","MATE","MOT","FIS","FILO","ITA","ITA","LAT","LAT","FILO","INGL","ITA","ARTE","","","","","",""],"1F":["SCI","INGL","FIS","ITA","REL","MOT","FIS","MATE","STO/GEO","STO/GEO","INGL","MOT","ARTE","ITA","ARTE","INGL","MATE","MATE","ITA","STO/GEO","MATE","SCI","MATE","INFO","ITA","INFO","","","SCI","","","","","","",""],"5M":["FILO","MATE","FIS","ITA","REL","INFO","STO","MATE","STO","ITA","FIS","MATE","SCI","ITA","INGL","FIS","SCI","ARTE","ARTE","SCI","SCI","INFO","FILO","ITA","INGL","MOT","SCI","MATE","INGL","","","MOT","","","",""],"1L":["FIS","MATE","ARTE","FIS","ITA","","INFO","SCI","INFO","INGL","STO/GEO","","INGL","INGL","ITA","STO/GEO","SCI","","ITA","ARTE","ITA","MATE","REL","","MOT","STO/GEO","MATE","MATE","MATE","","MOT","","","SCI","",""],"1H":["INGL","ARTE","STO/GEO","STO/GEO","STO/GEO","LAT","ARTE","MATE","LAT","ITA","LAT","SCI","SCI","INGL","MATE","ITA","REL","MOT","MATE","ITA","ITA","FIS","MATE","MOT","MATE","FIS","INGL","","","","","","","","",""],"1B":["STO/GEO","MATE","MOT","LAT","FIS","STO/GEO","LAT","MATE","MOT","REL","ARTE","MATE","MATE","FIS","ITA","INGL","ARTE","LAT","INGL","SCI","MATE","ITA","STO/GEO","SCI","","","INGL","ITA","ITA","","","","","","",""],"1D":["SCI","LAT","STO/GEO","MOT","MATE","FIS","MATE","LAT","SCI","MOT","STO/GEO","STO/GEO","ITA","MATE","MATE","FIS","ITA","MATE","REL","INGL","ARTE","ITA","LAT","INGL","","","ARTE","ITA","INGL","","","","","","",""],"5N":["INGL","INFO","FILO","STO","SCI","ARTE","ITA","MATE","MATE","FIS","FILO","ITA","SCI","FIS","MATE","INGL","INFO","INGL","FIS","SCI","SCI","ARTE","ITA","MATE","REL","MOT","STO","SCI","ITA","","","MOT","","","",""],"2C":["MOT","FIS","MATE","ITA","STO/GEO","INFO","MOT","STO/GEO","MATE","ITA","ARTE","SCI","INFO","REL","INGL","ARTE","SCI","STO/GEO","ITA","INGL","FIS","SCI","INGL","MATE","MATE","SCI","ITA","","","","","","","","",""],"1E":["FIS","MOT","STO/GEO","MATE","MATE","ITA","STO/GEO","MOT","LAT","MATE","FIS","ITA","INGL","INGL POT","ITA","INGL POT","STO/GEO","ARTE","LAT","SCI","INGL","ARTE","INGL","MATE","REL","MATE","SCI","LAT","ITA","","","","","","",""],"5A":["ARTE","LAT","MATE","SCI","MATE","FIS","STO","MATE","FILO","FIS","MATE","SCI","FILO","ITA","INGL","LAT","FILO","INGL","REL","ITA","SCI","INGL","ITA","LAT","MOT","ARTE","FIS","STO","ITA","","MOT","","","","",""],"4F":["INFO","REL","STO","INGL","ITA","SCI","ARTE","SCI","SCI","MATE","ITA","SCI","ITA","INGL","MOT","MATE","ARTE","INFO","INGL","FIS","MOT","FIS","FIS","STO","MATE","ITA","MATE","SCI","FILO","FILO","","","","","",""],"5B":["FIS","MATE","SCI","MOT","SCI","ARTE","REL","ITA","STO","MOT","FIS","FILO","FILO","ITA","FIS","MATE","INGL","SCI","STO","ARTE","ITA","LAT","MATE","LAT","INGL","INGL","LAT","FILO","MATE","ITA","","","","","",""],"5L":["LAT","LAT","MATE","LAT","ITA","FILO","REL","INGL","MATE","ITA","ITA","ARTE","FIS","MOT","STO","INGL","FILO","SCI","ITA","MOT","FILO","SCI","ARTE","INGL","MATE","FIS","SCI","FIS","MATE","STO","","","","","",""],"4C":["FIS","INGL","INGL","ARTE","ARTE","FIS","MATE","REL","FIS","INGL","ITA","STO","SCI","INFO","ITA","SCI","MOT","ITA","FILO","SCI","ITA","MATE","MOT","MATE","STO","FILO","INFO","MATE","SCI","SCI","","","","","",""],"4E":["INGL","INGL","FILO","ARTE","ITA","LAT","MATE","LAT","INGL","SCI","ITA","FILO","MATE","ITA","MOT","MATE","STO","ITA","LAT","FIS","MOT","INGL POT","FIS","ARTE","SCI","SCI","MATE","FIS","REL","STO","","","","","FILO",""],"3L":["STO","FILO","STO","REL","SCI","FILO","SCI","ARTE","SCI","MATE","FIS","SCI","ARTE","SCI","MATE","MATE","MOT","INGL","FIS","ITA","INGL","ITA","MOT","INFO","MATE","INFO","FIS","ITA","INGL","ITA","","","","","",""],"4G":["FILO","SCI","SCI","ITA","STO","ARTE","SCI","FILO","REL","INFO","ITA","MATE","FIS","ITA","MOT","SCI","ITA","FIS","MATE","INGL","MOT","STO","MATE","INFO","MATE","ARTE","FIS","INGL","SCI","INGL","","","","","",""],"2G":["SCI","INGL","MOT","INFO","STO/GEO","STO/GEO","MATE","ITA","MOT","FIS","SCI","ITA","ARTE","SCI","SCI","REL","INGL","ITA","INFO","MATE","FIS","MATE","MATE","ARTE","INGL","STO/GEO","","ITA","","","","","","","",""],"1A":["MOT","STO/GEO","INGL","REL","MATE","INGL","MOT","ARTE","MATE","FIS","ITA","LAT","MATE","ARTE","LAT","ITA","FIS","MATE","INGL","SCI","STO/GEO","ITA","STO/GEO","MATE","","LAT","ITA","","SCI","","","","","","",""],"5G":["INGL","MOT","SCI","INFO","ARTE","INGL","MATE","MOT","FILO","FIS","INGL","ARTE","MATE","FILO","FIS","MATE","SCI","INFO","STO","MATE","STO","ITA","SCI","ITA","SCI","FIS","ITA","SCI","REL","ITA","","","","","",""],"1I":["MATE","MATE","LAT","SCI","MATE","MOT","INGL","STO/GEO","STO/GEO","INGL","LAT","MOT","ITA","ARTE","REL","MATE","SCI","ITA","FIS","ITA","FIS","STO/GEO","ARTE","INGL","","ITA","MATE","LAT","","","","","","","",""],"4H":["MATE","SCI","FIS","MATE","LAT","ITA","MATE","FILO","SCI","SCI","ITA","ITA","REL","LAT","INGL","FILO","MOT","FIS","INGL","INGL","ARTE","STO","MOT","LAT","FIS","STO","ITA","ARTE","FILO","MATE","","","","","",""],"5I":["FIS","MATE","MATE","SCI","MATE","REL","ITA","MATE","FILO","ITA","ARTE","FIS","MOT","FILO","STO","ITA","SCI","INGL","MOT","LAT","FIS","INGL","LAT","STO","ARTE","INGL","SCI","LAT","ITA","FILO","","","","","",""],"3I":["FILO","ARTE","INGL","FILO","FIS","ITA","MATE","MATE","ARTE","LAT","SCI","ITA","LAT","LAT","FILO","ITA","MATE","SCI","REL","SCI","ITA","STO","MATE","FIS","INGL","FIS","STO","INGL","MOT","","","","","","MOT",""],"3G":["MATE","FILO","ITA","FIS","SCI","FIS","MATE","ITA","ITA","INFO","MATE","INGL","STO","MOT","REL","FILO","MATE","SCI","SCI","MOT","ARTE","INGL","INGL","ITA","INFO","SCI","SCI","STO","FIS","ARTE","","","","","",""],"2D":["LAT","SCI","STO/GEO","SCI","MOT","MATE","STO/GEO","LAT","MATE","ARTE","MOT","REL","ITA","INGL","ARTE","ITA","MATE","INGL","MATE","MATE","ITA","ITA","INGL","FIS","","STO/GEO","","FIS","LAT","","","","","","",""],"1N":["FIS","MATE","MATE","MATE","FIS","","LAT","SCI","ARTE","SCI","REL","","ITA","ITA","INGL","STO/GEO","MATE","","MATE","INGL","LAT","LAT","ITA","","INGL","ARTE","STO/GEO","MOT","ITA","","STO/GEO","","","MOT","",""],"3C":["REL","FILO","INGL","MATE","INGL","SCI","ITA","INGL","FIS","MATE","INFO","SCI","ITA","FIS","MATE","MOT","ARTE","FILO","SCI","INFO","ITA","MOT","SCI","STO","FIS","SCI","ARTE","STO","ITA","MATE","","","","","",""],"2H":["SCI","MATE","ITA","INGL","STO/GEO","LAT","MATE","LAT","INGL","SCI","MATE","STO/GEO","FIS","ITA","FIS","ITA","MATE","MOT","LAT","ARTE","MATE","ITA","REL","MOT","INGL","","","STO/GEO","ARTE","","","","","","",""],"4B":["SCI","FILO","REL","ARTE","SCI","FIS","INGL","STO","INGL","FILO","INGL","LAT","MOT","MATE","FIS","STO","LAT","ARTE","MOT","ITA","MATE","FIS","MATE","SCI","FILO","ITA","ITA","LAT","MATE","ITA","","","","","",""],"5H":["ARTE","ITA","FILO","MATE","LAT","FILO","REL","ARTE","INGL","INGL","STO","SCI","SCI","LAT","ITA","LAT","MATE","MOT","FIS","FIS","ITA","SCI","MATE","MOT","ITA","MATE","STO","FIS","FILO","INGL","","","","","",""],"2N":["MATE","REL","SCI","ITA","INGL","","LAT","INGL","LAT","ITA","MATE","","INGL","ITA","MATE","ARTE","FIS","","ITA","LAT","FIS","MATE","ARTE","","STO/GEO","STO/GEO","MOT","MATE","SCI","","","","MOT","","STO/GEO",""],"3D":["SCI","STO","LAT","INGL","MATE","INGL","MATE","FILO","LAT","FILO","INGL","ITA","ITA","FIS","FIS","STO","LAT","ITA","FIS","ARTE","MATE","SCI","FILO","SCI","MOT","MATE","ARTE","REL","ITA","","MOT","","","","",""],"4A":["LAT","FILO","INGL","LAT","MOT","SCI","SCI","STO","REL","ARTE","MOT","FILO","FIS","INGL","FIS","INGL","FILO","STO","MATE","LAT","ITA","MATE","SCI","MATE","ARTE","ITA","ITA","MATE","FIS","ITA","","","","","",""],"3B":["REL","INGL","INGL","FIS","FIS","INGL","FIS","ITA","MATE","LAT","FILO","FILO","MATE","LAT","SCI","MATE","STO","ITA","STO","MATE","FILO","ARTE","ITA","LAT","SCI","ARTE","MOT","SCI","ITA","","","","MOT","","",""],"3F":["ITA","INGL","ARTE","FIS","FILO","SCI","INGL","SCI","FIS","REL","SCI","FIS","INFO","MATE","STO","ITA","MATE","MATE","STO","FILO","ITA","ITA","MATE","INGL","SCI","ARTE","SCI","INFO","MOT","","","","","","MOT",""],"1G":["MOT","SCI","MATE","ARTE","ITA","SCI","MOT","MATE","ARTE","ITA","MATE","INGL","FIS","FIS","SCI","MATE","STO/GEO","ITA","MATE","INFO","INGL","STO/GEO","INFO","ITA","","STO/GEO","","REL","INGL","","","","","","",""],"2E":["ITA","MOT","LAT","INGL","STO/GEO","MATE","ITA","MOT","ITA","SCI","INGL","INGL","MATE","SCI","FIS","STO/GEO","FIS","LAT","MATE","ARTE","INGL POT","MATE","MATE","STO/GEO","ARTE","ITA","REL","LAT","","","","","","","",""],"1M":["ITA","MATE","REL","MATE","MATE","STO/GEO","ITA","INGL","MATE","FIS","ITA","INFO","MATE","SCI","FIS","MOT","ITA","INGL","INFO","STO/GEO","ARTE","MOT","SCI","SCI","","","ARTE","INGL","STO/GEO","","","","","","",""],"3E":["MATE","ARTE","STO","LAT","STO","ARTE","MATE","SCI","INGL","LAT","FILO","LAT","SCI","MATE","INGL POT","FILO","MATE","INGL","FILO","ITA","SCI","INGL","REL","ITA","FIS","FIS","MOT","ITA","FIS","ITA","","","MOT","","",""]}'; // TODO: deve essere downloadato da internet... e se lo mettessimo sulla repo di github?
final Map orari = jsonDecode(jsonData);

/*Future<void> _getImage(String url, String cls) async {
  http.Response r = await http.get(url);
  if (r.statusCode != HttpStatus.ok) return;
  orari[cls] = Image.memory(r.bodyBytes);
}*/
