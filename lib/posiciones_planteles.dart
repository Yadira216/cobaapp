
import 'package:flutter/material.dart';

class PosicionesPlanteles {

  // MAPA CEMSAD
// Coordenadas normalizadas con claves CCT verificadas (15 centros).
static const Map<String, Offset> cemsadValleToluca = {

  // Zona centro-norte y noroeste
  '15EMS0023K': Offset(0.5765, 0.4395), // 22 Enthavi
  '15EMS0018Z': Offset(0.5110, 0.4620), // 17 San Agustín Citlalli
  '15EMS0015B': Offset(0.4150, 0.4675), // 18 Bosencheve Loma de Juárez
  '15EMS0007T': Offset(0.3735, 0.4765), // 06 San Simón de la Laguna
  '15EMS0022L': Offset(0.3735, 0.4910), // 20 San Juan Xoconusco
  '15EMS0002Y': Offset(0.3715, 0.5085), // 02 Ixtapan del Oro

  // Zona centro-sur
  '15EMS0006U': Offset(0.4510, 0.5735), // 05 San Francisco Oxtotilpan
  '15EMS0011F': Offset(0.4675, 0.6180), // 10 Texcapilla
  '15EMS0014C': Offset(0.6060, 0.6455), // 14 San Andrés Nicolás Bravo
  '15EMS0005V': Offset(0.6380, 0.5960), // 07 San Juan Atzingo

  // Zona suroeste y sur profundo
  '15EMS0003X': Offset(0.3305, 0.6165), // 04 Cañadas de Nanchititla
  '15EMS0012E': Offset(0.4565, 0.6820), // 12 San Miguel Totolmaloya
  '15EMS0001Z': Offset(0.3690, 0.6820), // 03 El Salitre Palmarillos
  '15EMS0017Z': Offset(0.3690, 0.6975), // 15 San Simón Zozocoltepec
  '15EMS0024J': Offset(0.3715, 0.7495), // 23 Mayaltepec
};

  // MAPA VALLE DE MÉXICO
  // Coordenadas normalizadas verificadas con la imagen original (32 planteles).
    static const Map<String, Offset> valleMexico = {


    // Zona norte 
    '15ECB0059S': Offset(0.7393, 0.3000), // 50 Hueypoxtla
    '15ECB0044Q': Offset(0.6710, 0.3359), // 33 Huehuetoca
    '15ECB0053Y': Offset(0.7178, 0.3380), // 42 Zumpango
    '15ECB0027Z': Offset(0.6890, 0.3530), // 16 Coyotepec
    '15ECB0063E': Offset(0.8155, 0.3528), // 52 Axapusco
    '15ECB0065C': Offset(0.6999, 0.3600), // 54 Teoloyucan
    '15ECB0073L': Offset(0.7130, 0.3780), // 62 Melchor Ocampo
    '15ECB0068Z': Offset(0.7255, 0.3610), // 57 Jaltenco
    '15ECB0030N': Offset(0.7510, 0.3690), // 19 Tecámac
    '15ECB0046O': Offset(0.7510, 0.3835), // 35 Tecámac II
    '15ECB0072M': Offset(0.7875, 0.3889), // 61 Teotihuacán
    '15ECB0020G': Offset(0.8290, 0.3920), // 11 Otumba (corregido)


    // Zona centro-norte 
    '15ECB0026A': Offset(0.6290, 0.3969), // 15 Nicolás Romero
    '15ECB0060H': Offset(0.6285, 0.4385), // 48 Jilotzingo
    '15ECB0036H': Offset(0.6990, 0.4030), // 25 Tultitlán (corregido)
    '15ECB0002R': Offset(0.7355, 0.4060), // 02 Ecatepec
    '15ECB0014W': Offset(0.7355, 0.4210), // 10 Ecatepec II
    '15ECB0050A': Offset(0.7715, 0.3983), // 39 Acolman
    '15ECB0034J': Offset(0.7355, 0.4360), // 23 Ecatepec III


    // Zona centro-oeste y Texcoco 
    '15ECB0048M': Offset(0.6590, 0.4480), // 37 Naucalpan (corregido)
    '15ECB0054X': Offset(0.7975, 0.4480), // 43 Texcoco
    '15ECB0012Y': Offset(0.6380, 0.4700), // 09 Huixquilucan
    '15ECB0028Z': Offset(0.6380, 0.4845), // 17 Huixquilucan II


    // Zona oriente y sur 
    '15ECB0041T': Offset(0.7270, 0.4710), // 30 Nezahualcóyotl
    '15ECB0003Q': Offset(0.7590, 0.4573), // 03 Chimalhuacán
    '15ECB0035I': Offset(0.7590, 0.4743), // 24 Chimalhuacán II
    '15ECB0033K': Offset(0.7805, 0.4730), // 22 Chicoloapan
    '15ECB0042S': Offset(0.7805, 0.4875), // 31 Chicoloapan II
    '15ECB0029Y': Offset(0.8035, 0.4945), // 18 Ixtapaluca
    '15ECB0067A': Offset(0.8240, 0.4945), // 56 Ixtapaluca II
    '15ECB0004P': Offset(0.7640, 0.5140), // 04 Valle de Chalco (corregido)
    '15ECB0055W': Offset(0.8285, 0.5385), // 44 Tlalmanalco
  };


  
   // MAPA VALLE DE TOLUCA
   // Coordenadas normalizadas ajustadas al centro exacto (microajuste X).
    static const Map<String, Offset> valleToluca = {
    

    // Zona norte
    '15ECB0078G': Offset(0.5131, 0.2494), // 67 Aculco
    '15ECB0079F': Offset(0.6195, 0.2782), // 68 Soyaniquilpan
    '15ECB0045P': Offset(0.6195, 0.3931), // 34 Villa del Carbón
    '15ECB0038F': Offset(0.5150, 0.3000), // 27 Acambay
    '15ECB0052Z': Offset(0.4476, 0.3125), // 41 Temascalcingo
    '15ECB0049L': Offset(0.5160, 0.3149), // 38 Acambay II
    '15ECB0077H': Offset(0.4593, 0.3265), // 66 Temascalcingo II
    '15ECB0061G': Offset(0.4330, 0.3500), // 49 El Oro
    '15ECB0008L': Offset(0.5131, 0.3511), // 08 Atlacomulco
    '15ECB0062F': Offset(0.5667, 0.3662), // 51 Morelos
    '15ECB0076I': Offset(0.5738, 0.3805), // 65 Morelos II
    '15ECB0025B': Offset(0.5335, 0.3921), // 14 Jocotitlán
    '15ECB0031M': Offset(0.6000, 0.3520), // 20 Chapa de Mota
    '15ECB0040U': Offset(0.4155, 0.4135), // 29 San José del Rincón
    '15ECB0069Z': Offset(0.5677, 0.4255), // 58 Jiquipilco
    '15ECB0051Z': Offset(0.5170, 0.4270), // 40 Ixtlahuaca


    // Zona centro
    '15ECB0071N': Offset(0.5775, 0.4660), // 60 Temoaya
    '15ECB0074K': Offset(0.4662, 0.4732), // 63 Villa Victoria
    '15ECB0057U': Offset(0.6156, 0.4732), // 46 Xonacatlán
    '15ECB0023D': Offset(0.5199, 0.4864), // 12 Almoloya de Juárez
    '15ECB0006N': Offset(0.5600, 0.4959), // 06 Toluca
    '15ECB0007M': Offset(0.5600, 0.5104), // 07 Toluca II
    '15ECB0043R': Offset(0.5600, 0.5245), // 32 Toluca III
    '15ECB0075J': Offset(0.4652, 0.5347), // 64 Amanalco
    '15ECB0066B': Offset(0.5600, 0.5392), // 55 Toluca IV


    // Zona sur
    '15ECB0001S': Offset(0.5219, 0.5405), // 01 Zinacantepec
    '15ECB0039E': Offset(0.5219, 0.5560), // 28 Zinacantepec II
    '15ECB0005O': Offset(0.4233, 0.5562), // 05 Valle de Bravo
    '15ECB0024C': Offset(0.5707, 0.5565), // 13 Calimaya
    '15ECB0056V': Offset(0.5708, 0.5714), // 45 Calimaya II
    '15ECB0032L': Offset(0.5522, 0.6174), // 21 Villa Guerrero
    '15ECB0058T': Offset(0.5717, 0.5922), // 47 Tenango del Valle
    '15ECB0037G': Offset(0.5808, 0.6260), // 26 Tenancingo
    '15ECB0064D': Offset(0.5190, 0.6301), // 53 Coatepec Harinas
    '15ECB0047N': Offset(0.5521, 0.6326), // 36 Villa Guerrero II
    '15ECB0070O': Offset(0.5903, 0.6846), // 59 Zumpahuacán
  };
}