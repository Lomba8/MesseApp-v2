import 'dart:convert';

import 'package:Messedaglia/main.dart';
import 'package:Messedaglia/registro/registro.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String jsonData =
    '{"5B":["FIS","MATE","SCI","MOT","SCI","ARTE","REL","ITA","STO","MOT","FIS","FILO","FILO","ITA","FIS","MATE","INGL","SCI","STO","ARTE","ITA","LAT","MATE","LAT","INGL","INGL","LAT","FILO","MATE","ITA","","","","","",""],"5Burl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002603p00001s3fffffffffffffff_5b_ac.png","2I":["STO/GEO","ITA","STO/GEO","FIS","LAT","","REL","ITA","INGL","LAT","ITA","","FIS","MATE","MATE","INGL","STO/GEO","","SCI","LAT","ITA","MATE","SCI","","INGL","MOT","ARTE","MATE","MATE","","","MOT","","ARTE","",""],"2Iurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002617p00001s3fffffffffffffff_2i_ac.png","1F":["SCI","INGL","FIS","ITA","REL","MOT","FIS","MATE","STO/GEO","STO/GEO","INGL","MOT","ARTE","ITA","ARTE","INGL","MATE","MATE","ITA","STO/GEO","MATE","SCI","MATE","INFO","ITA","INFO","","","SCI","","","","","","",""],"1Furl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002569p00001s3fffffffffffffff_1f_ac.png","5E":["ARTE","FIS","LAT","LAT","ARTE","MATE","MATE","INGL","ITA","FIS","INGL","MATE","FILO","SCI","MOT","ITA","ITA","LAT","INGL","REL","MOT","ITA","SCI","FILO","STO","FILO","STO","SCI","MATE","FIS","","","","","",""],"5Eurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002595p00001s3fffffffffffffff_5e_ac.png","5D":["STO","ITA","MATE","INGL","SCI","MATE","ARTE","ITA","FIS","FIS","SCI","ARTE","FILO","INGL","ITA","SCI","MOT","FIS","INFO","FILO","INFO","MATE","MOT","INGL","SCI","SCI","REL","MATE","STO","ITA","","","","","",""],"5Durl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002594p00001s3fffffffffffffff_5d_ac.png","1I":["MATE","MATE","LAT","SCI","MATE","MOT","INGL","STO/GEO","STO/GEO","INGL","LAT","MOT","ITA","ARTE","REL","MATE","SCI","ITA","FIS","ITA","FIS","STO/GEO","ARTE","INGL","","ITA","MATE","LAT","","","","","","","",""],"1Iurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002608p00001s3fffffffffffffff_1i_ac.png","3F":["ITA","INGL","ARTE","FIS","FILO","SCI","INGL","SCI","FIS","REL","SCI","FIS","INFO","MATE","STO","ITA","MATE","MATE","STO","FILO","ITA","ITA","MATE","INGL","SCI","ARTE","SCI","INFO","MOT","","","","","","MOT",""],"3Furl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002584p00001s3fffffffffffffff_3f_ac.png","1H":["INGL","ARTE","STO/GEO","STO/GEO","STO/GEO","LAT","ARTE","MATE","LAT","ITA","LAT","SCI","SCI","INGL","MATE","ITA","REL","MOT","MATE","ITA","ITA","FIS","MATE","MOT","MATE","FIS","INGL","","","","","","","","",""],"1Hurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002571p00001s3fffffffffffffff_1h_ac.png","1A":["MOT","STO/GEO","INGL","REL","MATE","INGL","MOT","ARTE","MATE","FIS","ITA","LAT","MATE","ARTE","LAT","ITA","FIS","MATE","INGL","SCI","STO/GEO","ITA","STO/GEO","MATE","","LAT","ITA","","SCI","","","","","","",""],"1Aurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002564p00001s3fffffffffffffff_1a_ac.png","3G":["MATE","FILO","ITA","FIS","SCI","FIS","MATE","ITA","ITA","INFO","MATE","INGL","STO","MOT","REL","FILO","MATE","SCI","SCI","MOT","ARTE","INGL","INGL","ITA","INFO","SCI","SCI","STO","FIS","ARTE","","","","","",""],"3Gurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002585p00001s3fffffffffffffff_3g_ac.png","5N":["INGL","INFO","FILO","STO","SCI","ARTE","ITA","MATE","MATE","FIS","FILO","ITA","SCI","FIS","MATE","INGL","INFO","INGL","FIS","SCI","SCI","ARTE","ITA","MATE","REL","MOT","STO","SCI","ITA","","","MOT","","","",""],"5Nurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002614p00001s3fffffffffffffff_5n_ac.png","2N":["MATE","REL","SCI","ITA","INGL","","LAT","INGL","LAT","ITA","MATE","","INGL","ITA","MATE","ARTE","FIS","","ITA","LAT","FIS","MATE","ARTE","","STO/GEO","STO/GEO","MOT","MATE","SCI","","","","MOT","","STO/GEO",""],"2Nurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002620p00001s3fffffffffffffff_2n_ac.png","4D":["ITA","MATE","ARTE","FILO","FILO","SCI","LAT","SCI","ITA","INGL","FIS","FIS","MOT","LAT","ITA","LAT","STO","ARTE","MOT","INGL","MATE","REL","FIS","MATE","FILO","STO","MATE","SCI","ITA","INGL","","","","","",""],"4Durl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002588p00001s3fffffffffffffff_4d_ac.png","4G":["FILO","SCI","SCI","ITA","STO","ARTE","SCI","FILO","REL","INFO","ITA","MATE","FIS","ITA","MOT","SCI","ITA","FIS","MATE","INGL","MOT","STO","MATE","INFO","MATE","ARTE","FIS","INGL","SCI","INGL","","","","","",""],"4Gurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002591p00001s3fffffffffffffff_4g_ac.png","1G":["MOT","SCI","MATE","ARTE","ITA","SCI","MOT","MATE","ARTE","ITA","MATE","INGL","FIS","FIS","SCI","MATE","STO/GEO","ITA","MATE","INFO","INGL","STO/GEO","INFO","ITA","","STO/GEO","","REL","INGL","","","","","","",""],"1Gurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002570p00001s3fffffffffffffff_1g_ac.png","2M":["MATE","STO/GEO","STO/GEO","INGL","INGL","ARTE","INFO","ITA","ARTE","SCI","SCI","FIS","MOT","REL","INGL","INFO","MATE","ITA","MOT","SCI","SCI","FIS","STO/GEO","ITA","","MATE","ITA","MATE","","","","","","","",""],"2Murl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002619p00001s3fffffffffffffff_2m_ac.png","1D":["SCI","LAT","STO/GEO","MOT","MATE","FIS","MATE","LAT","SCI","MOT","STO/GEO","STO/GEO","ITA","MATE","MATE","FIS","ITA","MATE","REL","INGL","ARTE","ITA","LAT","INGL","","","ARTE","ITA","INGL","","","","","","",""],"1Durl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002567p00001s3fffffffffffffff_1d_ac.png","2H":["SCI","MATE","ITA","INGL","STO/GEO","LAT","MATE","LAT","INGL","SCI","MATE","STO/GEO","FIS","ITA","FIS","ITA","MATE","MOT","LAT","ARTE","MATE","ITA","REL","MOT","INGL","","","STO/GEO","ARTE","","","","","","",""],"2Hurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002579p00001s3fffffffffffffff_2h_ac.png","5M":["FILO","MATE","FIS","ITA","REL","INFO","STO","MATE","STO","ITA","FIS","MATE","SCI","ITA","INGL","FIS","SCI","ARTE","ARTE","SCI","SCI","INFO","FILO","ITA","INGL","MOT","SCI","MATE","INGL","","","MOT","","","",""],"5Murl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002611p00001s3fffffffffffffff_5m_ac.png","2A":["REL","ARTE","MOT","ARTE","MATE","STO/GEO","MATE","INGL","MOT","LAT","FIS","LAT","ITA","FIS","SCI","STO/GEO","INGL","MATE","LAT","SCI","MATE","ITA","STO/GEO","INGL","","","MATE","ITA","ITA","","","","","","",""],"2Aurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002572p00001s3fffffffffffffff_2a_ac.png","3H":["REL","FIS","INGL","ITA","FIS","MATE","FILO","MATE","SCI","LAT","SCI","INGL","MATE","MOT","STO","SCI","ARTE","STO","MATE","MOT","FIS","FILO","ITA","ITA","LAT","LAT","FILO","INGL","ITA","ARTE","","","","","",""],"3Hurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002604p00001s3fffffffffffffff_3h_ac.png","1M":["ITA","MATE","REL","MATE","MATE","STO/GEO","ITA","INGL","MATE","FIS","ITA","INFO","MATE","SCI","FIS","MOT","ITA","INGL","INFO","STO/GEO","ARTE","MOT","SCI","SCI","","","ARTE","INGL","STO/GEO","","","","","","",""],"1Murl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002615p00001s3fffffffffffffff_1m_ac.png","4F":["INFO","REL","STO","INGL","ITA","SCI","ARTE","SCI","SCI","MATE","ITA","SCI","ITA","INGL","MOT","MATE","ARTE","INFO","INGL","FIS","MOT","FIS","FIS","STO","MATE","ITA","MATE","SCI","FILO","FILO","","","","","",""],"4Furl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002590p00001s3fffffffffffffff_4f_ac.png","2D":["LAT","SCI","STO/GEO","SCI","MOT","MATE","STO/GEO","LAT","MATE","ARTE","MOT","REL","ITA","INGL","ARTE","ITA","MATE","INGL","MATE","MATE","ITA","ITA","INGL","FIS","","STO/GEO","","FIS","LAT","","","","","","",""],"2Durl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002575p00001s3fffffffffffffff_2d_ac.png","5F":["INFO","ITA","MATE","MATE","SCI","SCI","ARTE","ITA","MATE","FIS","ARTE","FIS","MATE","SCI","STO","SCI","ITA","STO","INGL","REL","ITA","INFO","FIS","INGL","SCI","FILO","FILO","MOT","INGL","","","","","MOT","",""],"5Furl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002596p00001s3fffffffffffffff_5f_ac.png","3E":["MATE","ARTE","STO","LAT","STO","ARTE","MATE","SCI","INGL","LAT","FILO","LAT","SCI","MATE","INGL POT","FILO","MATE","INGL","FILO","ITA","SCI","INGL","REL","ITA","FIS","FIS","MOT","ITA","FIS","ITA","","","MOT","","",""],"3Eurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002583p00001s3fffffffffffffff_3e_ac.png","4C":["FIS","INGL","INGL","ARTE","ARTE","FIS","MATE","REL","FIS","INGL","ITA","STO","SCI","INFO","ITA","SCI","MOT","ITA","FILO","SCI","ITA","MATE","MOT","MATE","STO","FILO","INFO","MATE","SCI","SCI","","","","","",""],"4Curl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002587p00001s3fffffffffffffff_4c_ac.png","3I":["FILO","ARTE","INGL","FILO","FIS","ITA","MATE","MATE","ARTE","LAT","SCI","ITA","LAT","LAT","FILO","ITA","MATE","SCI","REL","SCI","ITA","STO","MATE","FIS","INGL","FIS","STO","INGL","MOT","","","","","","MOT",""],"3Iurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002621p00001s3fffffffffffffff_3i_ac.png","4E":["INGL","INGL","FILO","ARTE","ITA","LAT","MATE","LAT","INGL","SCI","ITA","FILO","MATE","ITA","MOT","MATE","STO","ITA","LAT","FIS","MOT","INGL POT","FIS","ARTE","SCI","SCI","MATE","FIS","REL","STO","","","","","FILO",""],"4Eurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002589p00001s3fffffffffffffff_4e_ac.png","4B":["SCI","FILO","REL","ARTE","SCI","FIS","INGL","STO","INGL","FILO","INGL","LAT","MOT","MATE","FIS","STO","LAT","ARTE","MOT","ITA","MATE","FIS","MATE","SCI","FILO","ITA","ITA","LAT","MATE","ITA","","","","","",""],"4Burl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002601p00001s3fffffffffffffff_4b_ac.png","2F":["ITA","SCI","STO/GEO","STO/GEO","ARTE","MATE","ITA","INFO","MATE","ITA","STO/GEO","INFO","INGL","ARTE","SCI","MOT","SCI","FIS","SCI","MATE","INGL","MOT","INGL","ITA","REL","MATE","FIS","","","","","","","","",""],"2Furl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002577p00001s3fffffffffffffff_2f_ac.png","1B":["STO/GEO","MATE","MOT","LAT","FIS","STO/GEO","LAT","MATE","MOT","REL","ARTE","MATE","MATE","FIS","ITA","INGL","ARTE","LAT","INGL","SCI","MATE","ITA","STO/GEO","SCI","","","INGL","ITA","ITA","","","","","","",""],"1Burl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002565p00001s3fffffffffffffff_1b_ac.png","2B":["SCI","STO/GEO","SCI","FIS","MOT","STO/GEO","INGL","ITA","LAT","INGL","MOT","ITA","REL","ARTE","ITA","MATE","FIS","MATE","MATE","LAT","ITA","MATE","STO/GEO","INGL","","MATE","","ARTE","LAT","","","","","","",""],"2Burl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002573p00001s3fffffffffffffff_2b_ac.png","2E":["ITA","MOT","LAT","INGL","STO/GEO","MATE","ITA","MOT","ITA","SCI","INGL","INGL","MATE","SCI","FIS","STO/GEO","FIS","LAT","MATE","ARTE","INGL POT","MATE","MATE","STO/GEO","ARTE","ITA","REL","LAT","","","","","","","",""],"2Eurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002576p00001s3fffffffffffffff_2e_ac.png","5C":["SCI","ARTE","MATE","MOT","INGL","FIS","STO","REL","MATE","MOT","STO","INGL","ARTE","FIS","FIS","INGL","SCI","FILO","ITA","SCI","SCI","MATE","FILO","SCI","ITA","MATE","ITA","ITA","INFO","INFO","","","","","",""],"5Curl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002593p00001s3fffffffffffffff_5c_ac.png","1E":["FIS","MOT","STO/GEO","MATE","MATE","ITA","STO/GEO","MOT","LAT","MATE","FIS","ITA","INGL","INGL POT","ITA","INGL POT","STO/GEO","ARTE","LAT","SCI","INGL","ARTE","INGL","MATE","REL","MATE","SCI","LAT","ITA","","","","","","",""],"1Eurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002568p00001s3fffffffffffffff_1e_ac.png","4A":["LAT","FILO","INGL","LAT","MOT","SCI","SCI","STO","REL","ARTE","MOT","FILO","FIS","INGL","FIS","INGL","FILO","STO","MATE","LAT","ITA","MATE","SCI","MATE","ARTE","ITA","ITA","MATE","FIS","ITA","","","","","",""],"4Aurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002586p00001s3fffffffffffffff_4a_ac.png","5G":["INGL","MOT","SCI","INFO","ARTE","INGL","MATE","MOT","FILO","FIS","INGL","ARTE","MATE","FILO","FIS","MATE","SCI","INFO","STO","MATE","STO","ITA","SCI","ITA","SCI","FIS","ITA","SCI","REL","ITA","","","","","",""],"5Gurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002597p00001s3fffffffffffffff_5g_ac.png","2G":["SCI","INGL","MOT","INFO","STO/GEO","STO/GEO","MATE","ITA","MOT","FIS","SCI","ITA","ARTE","SCI","SCI","REL","INGL","ITA","INFO","MATE","FIS","MATE","MATE","ARTE","INGL","STO/GEO","","ITA","","","","","","","",""],"2Gurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002578p00001s3fffffffffffffff_2g_ac.png","5A":["ARTE","LAT","MATE","SCI","MATE","FIS","STO","MATE","FILO","FIS","MATE","SCI","FILO","ITA","INGL","LAT","FILO","INGL","REL","ITA","SCI","INGL","ITA","LAT","MOT","ARTE","FIS","STO","ITA","","MOT","","","","",""],"5Aurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002592p00001s3fffffffffffffff_5a_ac.png","4H":["MATE","SCI","FIS","MATE","LAT","ITA","MATE","FILO","SCI","SCI","ITA","ITA","REL","LAT","INGL","FILO","MOT","FIS","INGL","INGL","ARTE","STO","MOT","LAT","FIS","STO","ITA","ARTE","FILO","MATE","","","","","",""],"4Hurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002605p00001s3fffffffffffffff_4h_ac.png","1N":["FIS","MATE","MATE","MATE","FIS","","LAT","SCI","ARTE","SCI","REL","","ITA","ITA","INGL","STO/GEO","MATE","","MATE","INGL","LAT","LAT","ITA","","INGL","ARTE","STO/GEO","MOT","ITA","","STO/GEO","","","MOT","",""],"1Nurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002616p00001s3fffffffffffffff_1n_ac.png","2L":["ARTE","FIS","STO/GEO","MATE","ITA","","ITA","ARTE","SCI","MATE","MATE","","ITA","INGL","MATE","SCI","INFO","","SCI","STO/GEO","REL","ITA","INGL","","INFO","SCI","INGL","FIS","MOT","","","","","STO/GEO","MOT",""],"2Lurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002618p00001s3fffffffffffffff_2l_ac.png","2C":["MOT","FIS","MATE","ITA","STO/GEO","INFO","MOT","STO/GEO","MATE","ITA","ARTE","SCI","INFO","REL","INGL","ARTE","SCI","STO/GEO","ITA","INGL","FIS","SCI","INGL","MATE","MATE","SCI","ITA","","","","","","","","",""],"2Curl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002574p00001s3fffffffffffffff_2c_ac.png","3C":["REL","FILO","INGL","MATE","INGL","SCI","ITA","INGL","FIS","MATE","INFO","SCI","ITA","FIS","MATE","MOT","ARTE","FILO","SCI","INFO","ITA","MOT","SCI","STO","FIS","SCI","ARTE","STO","ITA","MATE","","","","","",""],"3Curl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002581p00001s3fffffffffffffff_3c_ac.png","5I":["FIS","MATE","MATE","SCI","MATE","REL","ITA","MATE","FILO","ITA","ARTE","FIS","MOT","FILO","STO","ITA","SCI","INGL","MOT","LAT","FIS","INGL","LAT","STO","ARTE","INGL","SCI","LAT","ITA","FILO","","","","","",""],"5Iurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002607p00001s3fffffffffffffff_5i_ac.png","3L":["STO","FILO","STO","REL","SCI","FILO","SCI","ARTE","SCI","MATE","FIS","SCI","ARTE","SCI","MATE","MATE","MOT","INGL","FIS","ITA","INGL","ITA","MOT","INFO","MATE","INFO","FIS","ITA","INGL","ITA","","","","","",""],"3Lurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002622p00001s3fffffffffffffff_3l_ac.png","1C":["STO/GEO","SCI","INGL","SCI","INGL","MOT","SCI","MATE","STO/GEO","INGL","FIS","MOT","MATE","ITA","INFO","ITA","REL","INFO","ARTE","ITA","ARTE","FIS","MATE","MATE","ITA","","MATE","STO/GEO","","","","","","","",""],"1Curl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002566p00001s3fffffffffffffff_1c_ac.png","1L":["FIS","MATE","ARTE","FIS","ITA","","INFO","SCI","INFO","INGL","STO/GEO","","INGL","INGL","ITA","STO/GEO","SCI","","ITA","ARTE","ITA","MATE","REL","","MOT","STO/GEO","MATE","MATE","MATE","","MOT","","","SCI","",""],"1Lurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002609p00001s3fffffffffffffff_1l_ac.png","5L":["LAT","LAT","MATE","LAT","ITA","FILO","REL","INGL","MATE","ITA","ITA","ARTE","FIS","MOT","STO","INGL","FILO","SCI","ITA","MOT","FILO","SCI","ARTE","INGL","MATE","FIS","SCI","FIS","MATE","STO","","","","","",""],"5Lurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002610p00001s3fffffffffffffff_5l_ac.png","3D":["SCI","STO","LAT","INGL","MATE","INGL","MATE","FILO","LAT","FILO","INGL","ITA","ITA","FIS","FIS","STO","LAT","ITA","FIS","ARTE","MATE","SCI","FILO","SCI","MOT","MATE","ARTE","REL","ITA","","MOT","","","","",""],"3Durl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002582p00001s3fffffffffffffff_3d_ac.png","3B":["REL","INGL","INGL","FIS","FIS","INGL","FIS","ITA","MATE","LAT","FILO","FILO","MATE","LAT","SCI","MATE","STO","ITA","STO","MATE","FILO","ARTE","ITA","LAT","SCI","ARTE","MOT","SCI","ITA","","","","MOT","","",""],"3Burl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002598p00001s3fffffffffffffff_3b_ac.png","3A":["INGL","SCI","LAT","FILO","ARTE","FIS","ITA","INGL","STO","ITA","SCI","MATE","LAT","FILO","FILO","FIS","ITA","MATE","ARTE","MATE","REL","SCI","ITA","STO","FIS","LAT","INGL","MOT","MATE","","","","","MOT","",""],"3Aurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002580p00001s3fffffffffffffff_3a_ac.png","5H":["ARTE","ITA","FILO","MATE","LAT","FILO","REL","ARTE","INGL","INGL","STO","SCI","SCI","LAT","ITA","LAT","MATE","MOT","FIS","FIS","ITA","SCI","MATE","MOT","ITA","MATE","STO","FIS","FILO","INGL","","","","","",""],"5Hurl":"https://www.messedaglia.edu.it/images/stories/2019-20/orario/classi/edc0002606p00001s3fffffffffffffff_5h_ac.png"}'; // TODO: deve essere downloadato da internet... e se lo mettessimo sulla repo di github?
final Map orari = jsonDecode(jsonData);

String selectedClass;

void getSelected() => selectedClass = prefs.getString('selectedClass') ?? RegistroApi.cls;

final Map<String, Color> colors = {
  'ITA': Colors.white,
  'FIS': Color(0xFF95AABF),
  'STO': Color(0xFFDC78DC),
  'ARTE': Color(0xFF78DCAA),
  'SCI': Color(0xFFDC7878),
  'MATE': Color(0xFFDDF7F7),
  'INGL': Color(0xFFDCDC78),
  'LAT': Color(0xFFCEA286),
  'MOT': Color(0xFFDFD5CA),
  'REL': Color(0xFFB4B4B4),
  'FILO': Color(0xFFF7DDEA),
  'STO/GEO': Color(0xFFF7DDDD),
  'INFO': Color(0xFFE9D5C0),
  'INGL POT': Color(0xFFF2F2F2),
};
