import 'package:converterpro/utils/Utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "dart:convert";
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:units_converter/units_converter.dart';

class Conversions with ChangeNotifier {
  List<Property> _propertyList;
  List<List<UnitData>> _unitDataList = [];
  List<UnitData> currentUnitDataList;
  Property _currentProperty;
  UnitData _selectedUnit; //unit where the user is writing the value
  int _currentPage = 0; //from appModel
  //List<int> _currentOrder;
  DateTime _lastUpdateCurrencies = DateTime(2021, 2, 1); //1st of february 2021
  Map<CURRENCIES, double> _currencyValues = {
    CURRENCIES.EUR: 1.0,
    CURRENCIES.CAD: 1.5474,
    CURRENCIES.HKD: 9.3687,
    CURRENCIES.RUB: 91.6248,
    CURRENCIES.PHP: 58.083,
    CURRENCIES.DKK: 7.4373,
    CURRENCIES.NZD: 1.6844,
    CURRENCIES.CNY: 7.8143,
    CURRENCIES.AUD: 1.5831,
    CURRENCIES.RON: 4.8735,
    CURRENCIES.SEK: 10.1627,
    CURRENCIES.IDR: 17011.92,
    CURRENCIES.INR: 88.345,
    CURRENCIES.BRL: 6.5765,
    CURRENCIES.USD: 1.2084,
    CURRENCIES.ILS: 3.9739,
    CURRENCIES.JPY: 126.77,
    CURRENCIES.THB: 36.228,
    CURRENCIES.CHF: 1.0816,
    CURRENCIES.CZK: 25.975,
    CURRENCIES.MYR: 4.885,
    CURRENCIES.TRY: 8.6902,
    CURRENCIES.MXN: 24.5157,
    CURRENCIES.NOK: 10.389,
    CURRENCIES.HUF: 356.35,
    CURRENCIES.ZAR: 18.1574,
    CURRENCIES.SGD: 1.6092,
    CURRENCIES.GBP: 0.882,
    CURRENCIES.KRW: 1351.21,
    CURRENCIES.PLN: 4.508,
  };
  Map<CURRENCIES, String> _currenciesSymbols = {
    CURRENCIES.EUR: '€ 🇪🇺',
    CURRENCIES.CAD: '\$ 🇨🇦',
    CURRENCIES.HKD: 'HK\$ 🇭🇰',
    CURRENCIES.RUB: '₽ 🇷🇺',
    CURRENCIES.PHP: '₱ 🇵🇭',
    CURRENCIES.DKK: 'kr 🇩🇰',
    CURRENCIES.NZD: 'NZ\$ 🇳🇿',
    CURRENCIES.CNY: '¥ 🇨🇳',
    CURRENCIES.AUD: 'A\$ 🇦🇺',
    CURRENCIES.RON: 'L 🇷🇴',
    CURRENCIES.SEK: 'kr 🇸🇪',
    CURRENCIES.IDR: 'Rp 🇮🇩',
    CURRENCIES.INR: '₹ 🇮🇳',
    CURRENCIES.BRL: 'R\$ 🇧🇷',
    CURRENCIES.USD: '\$ 🇺🇸',
    CURRENCIES.ILS: '₪ 🇮🇱',
    CURRENCIES.JPY: '¥ 🇯🇵',
    CURRENCIES.THB: '฿ 🇹🇭',
    CURRENCIES.CHF: 'Fr. 🇨🇭',
    CURRENCIES.CZK: 'Kč 🇨🇿',
    CURRENCIES.MYR: 'RM 🇲🇾',
    CURRENCIES.TRY: '₺ 🇹🇷',
    CURRENCIES.MXN: '\$ 🇲🇽',
    CURRENCIES.NOK: 'kr 🇳🇴',
    CURRENCIES.HUF: 'Ft 🇭🇺',
    CURRENCIES.ZAR: 'R 🇿🇦',
    CURRENCIES.SGD: 'S\$ 🇸🇬',
    CURRENCIES.GBP: '£ 🇬🇧',
    CURRENCIES.KRW: '₩ 🇰🇷',
    CURRENCIES.PLN: 'zł 🇵🇱',
  };
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  static List<int> _orderLength = List.generate(16, (index) => index);
  static List<int> _orderArea = List.generate(11, (index) => index);
  static List<int> _orderVolume = List.generate(14, (index) => index);
  static List<int> _orderTime = List.generate(15, (index) => index);
  static List<int> _orderTemperature = List.generate(7, (index) => index);
  static List<int> _orderSpeed = List.generate(5, (index) => index);
  static List<int> _orderPrefixes = List.generate(21, (index) => index);
  static List<int> _orderMass = List.generate(11, (index) => index);
  static List<int> _orderPressure = List.generate(6, (index) => index);
  static List<int> _orderEnergy = List.generate(4, (index) => index);
  static List<int> _orderAngle = List.generate(4, (index) => index);
  static List<int> _orderCurrencies = List.generate(30, (index) => index);
  static List<int> _orderShoeSize = List.generate(10, (index) => index);
  static List<int> _orderData = List.generate(27, (index) => index);
  static List<int> _orderPower = List.generate(7, (index) => index);
  static List<int> _orderForce = List.generate(5, (index) => index);
  static List<int> _orderTorque = List.generate(5, (index) => index);
  static List<int> _orderFuelConsumption = List.generate(4, (index) => index);
  static List<int> _orderNumeralSystems = List.generate(4, (index) => index);
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  static List<List<int>> _conversionsOrder = [
    _orderLength,
    _orderArea,
    _orderVolume,
    _orderCurrencies,
    _orderTime,
    _orderTemperature,
    _orderSpeed,
    _orderMass,
    _orderForce,
    _orderFuelConsumption,
    _orderNumeralSystems,
    _orderPressure,
    _orderEnergy,
    _orderPower,
    _orderAngle,
    _orderShoeSize,
    _orderData,
    _orderPrefixes,
    _orderTorque,
  ];
  bool _isCurrenciesLoading = true;
  bool _removeTrailingZeros = true;
  static final List<int> _significantFiguresList = <int>[6, 8, 10, 12, 14];
  int _significantFigures = _significantFiguresList[2];

  Conversions() {
    _checkCurrencies(); //update the currencies with the latest conversions rates and then
    _checkOrdersUnits();
    _checkSettings();
    _refreshConversionsList();
  }

  ///This function initialize the propertyList, this property will do the real computations
  _refreshConversionsList() {
    _propertyList = [
      Length(significantFigures: _significantFigures, removeTrailingZeros: _removeTrailingZeros, name: PROPERTYX.LENGTH),
      Area(significantFigures: _significantFigures, removeTrailingZeros: _removeTrailingZeros, name: PROPERTYX.AREA),
      Volume(significantFigures: _significantFigures, removeTrailingZeros: _removeTrailingZeros, name: PROPERTYX.VOLUME),
      SimpleCustomConversion(_currencyValues,
          mapSymbols: _currenciesSymbols, significantFigures: _significantFigures, removeTrailingZeros: _removeTrailingZeros, name: PROPERTYX.CURRENCIES),
      Time(significantFigures: _significantFigures, removeTrailingZeros: _removeTrailingZeros, name: PROPERTYX.TIME),
      Temperature(significantFigures: _significantFigures, removeTrailingZeros: _removeTrailingZeros, name: PROPERTYX.TEMPERATURE),
      Speed(significantFigures: _significantFigures, removeTrailingZeros: _removeTrailingZeros, name: PROPERTYX.SPEED),
      Mass(significantFigures: _significantFigures, removeTrailingZeros: _removeTrailingZeros, name: PROPERTYX.MASS),
      Force(significantFigures: _significantFigures, removeTrailingZeros: _removeTrailingZeros, name: PROPERTYX.FORCE),
      FuelConsumption(significantFigures: _significantFigures, removeTrailingZeros: _removeTrailingZeros, name: PROPERTYX.FUEL_CONSUMPTION),
      NumeralSystems(name: PROPERTYX.NUMERAL_SYSTEMS),
      Pressure(significantFigures: _significantFigures, removeTrailingZeros: _removeTrailingZeros, name: PROPERTYX.PRESSURE),
      Energy(significantFigures: _significantFigures, removeTrailingZeros: _removeTrailingZeros, name: PROPERTYX.ENERGY),
      Power(significantFigures: _significantFigures, removeTrailingZeros: _removeTrailingZeros, name: PROPERTYX.POWER),
      Angle(significantFigures: _significantFigures, removeTrailingZeros: _removeTrailingZeros, name: PROPERTYX.ANGLE),
      ShoeSize(significantFigures: _significantFigures, removeTrailingZeros: _removeTrailingZeros, name: PROPERTYX.SHOE_SIZE),
      DigitalData(significantFigures: _significantFigures, removeTrailingZeros: _removeTrailingZeros, name: PROPERTYX.DIGITAL_DATA),
      SIPrefixes(significantFigures: _significantFigures, removeTrailingZeros: _removeTrailingZeros, name: PROPERTYX.SI_PREFIXES),
      Torque(significantFigures: _significantFigures, removeTrailingZeros: _removeTrailingZeros, name: PROPERTYX.TORQUE),
    ];
    _currentProperty = _propertyList[_currentPage];

    //Initialize of all the UnitData: name, textEditingController, symbol with the given order
    _refreshOrderUnits();
    //_currentOrder = _conversionsOrder[_currentPage];
  }

  /// This function get the value of the unit from currentProperty and update the currentUnitDataList values. It is used when a conversion changes the values of
  /// the units
  _refreshCurrentUnitDataList() {
    for (UnitData currentUnitData in currentUnitDataList) {
      currentUnitData.unit = _currentProperty.getUnit(currentUnitData.unit.name);
      if (currentUnitData != _selectedUnit && currentUnitData.unit.stringValue != null) {
        currentUnitData.tec.text = currentUnitData.unit.stringValue;
      } else if (currentUnitData.unit.stringValue == null) {
        currentUnitData.tec.text = '';
      }
    }
  }

  /// This function is used to convert all the values from one that has been modified
  convert(UnitData unitData, var value) {
    _currentProperty.convert(unitData.unit.name, value);
    _selectedUnit = unitData;
    _refreshCurrentUnitDataList();
    notifyListeners();
  }

  /// this method is used by AppModel to change the page that is showed
  set currentPage(int currentPage) {
    _currentPage = currentPage;
    _currentProperty = _propertyList[_currentPage];
    currentUnitDataList = _unitDataList[_currentPage];
    notifyListeners();
  }

  get currentPropertyName => _currentProperty.name;

  ///Clears the values of the current page
  clearAllValues() {
    convert(currentUnitDataList[0], null);
  }

  ///Returns the DateTime of the latest update of the currencies conversions
  ///ratio (year, month, day)
  get lastUpdateCurrency => _lastUpdateCurrencies;

  ///returns true if the currencies conversions ratio are not ready yet,
  ///returns false otherwise
  get isCurrenciesLoading => _isCurrenciesLoading;

  ///This method is used by _checkCurrencies to read the currencies conversions if
  ///the smartphone is offline
  _readSavedCurrencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currencyRead = prefs.getString("currencyRates");
    if (currencyRead != null) {
      CurrencyJSONObject currencyObject = new CurrencyJSONObject.fromJson(json.decode(currencyRead));
      _currencyValues = currencyObject.rates;
      _currencyValues.putIfAbsent(CURRENCIES.EUR, () => 1.0);
      String lastUpdateRead = currencyObject.date;
      if (lastUpdateRead != null) _lastUpdateCurrencies = DateTime.parse(lastUpdateRead);
    }
  }

  ///Updates the currencies conversions ratio with the latest values. The data comes from
  ///the internet if the connection is available or from memory if the smartphone is offline
  _checkCurrencies() async {
    String now = DateFormat("yyyy-MM-dd").format(DateTime.now());
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String dataFetched = prefs.getString("currencyRates");
    if (dataFetched == null || CurrencyJSONObject.fromJson(json.decode(dataFetched)).date != now) {
      //if I have never updated the conversions or if I have updated before today I have to update
      try {
        var response = await http.get(
            'https://api.exchangeratesapi.io/latest?symbols=USD,GBP,INR,CNY,JPY,CHF,SEK,RUB,CAD,KRW,BRL,HKD,AUD,NZD,MXN,SGD,NOK,TRY,ZAR,DKK,PLN,THB,MYR,HUF,CZK,ILS,IDR,PHP,RON');
        if (response.statusCode == 200) {
          //if successful
          CurrencyJSONObject currencyObject = new CurrencyJSONObject.fromJson(json.decode(response.body));
          //the following line solves the problem that the http request gives a date refered to some
          //time zone that may be not the same of the time zone of the user. So I rewrite the date of
          //the response to be the same of the date of the user
          currencyObject.date = now;
          _currencyValues = currencyObject.rates; //updates the currency value with the new values
          _currencyValues.putIfAbsent(CURRENCIES.EUR, () => 1.0);
          //If the request recive an accettable response the last update is now
          _lastUpdateCurrencies = DateTime.now();
          //save to memory
          prefs.setString("currencyRates", currencyObject.toString());
        } else //if there's some error in the data read (e.g. I'm not connected)
          await _readSavedCurrencies(); //read the saved data
      } catch (e) {
        //catch communication error
        print(e);
        await _readSavedCurrencies(); //read the saved data
      }
    } else {
      //If I already have the data of today I just use it, no need of read them from the web
      await _readSavedCurrencies();
      _lastUpdateCurrencies = DateTime.now();
    }
    _isCurrenciesLoading = false; // stop the progress indicator to show the date of the latest update
    _refreshConversionsList();
    notifyListeners(); //change the value of the current conversions
  }

  ///Get the orders of each units of measurement from the memory
  _checkOrdersUnits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> stringList;
    //Update every order of every conversion
    for (int i = 0; i < _propertyList.length; i++) {
      stringList = prefs.getStringList("conversion_$i");
      if (stringList != null) {
        final int len = stringList.length;
        List<int> intList = [];
        for (int j = 0; j < len; j++) {
          intList.add(int.parse(stringList[j]));
        }
        //solves the problem of adding new units after an update
        for (int j = len; j < _conversionsOrder[i].length; j++) intList.add(j);
        _conversionsOrder[i] = intList;
      }
    }
    _refreshOrderUnits();
    currentUnitDataList = _unitDataList[_currentPage];
    //_currentOrder = _conversionsOrder[_currentPage];
    notifyListeners();
  }

  /// Apply the order defined in [_conversionsOrder] to [_unitDataList]. [_unitDataList] will be redefined, so this function is used also during initialization
  _refreshOrderUnits() {
    _unitDataList = [];
    for (int i = 0; i < _propertyList.length; i++) {
      List<UnitData> tempUnitData = List.filled(_conversionsOrder[i].length, null);
      Property property = _propertyList[i];
      List<Unit> tempProperty = property.getAll();
      for (int j = 0; j < tempProperty.length; j++) {
        VALIDATOR validator = VALIDATOR.RATIONAL_NON_NEGATIVE;
        TextInputType textInputType = TextInputType.numberWithOptions(decimal: true, signed: false);
        if(property.name == PROPERTYX.NUMERAL_SYSTEMS){

          switch(tempProperty[j].name){
            case NUMERAL_SYSTEMS.binary:{
              validator = VALIDATOR.BINARY;
              textInputType = TextInputType.numberWithOptions(decimal: false, signed: false);
              break;
            }
            case NUMERAL_SYSTEMS.octal: {
              validator = VALIDATOR.OCTAL;
              textInputType = TextInputType.numberWithOptions(decimal: false, signed: false);
              break;
            }
            case NUMERAL_SYSTEMS.decimal: {
              validator = VALIDATOR.DECIMAL;
              textInputType = TextInputType.numberWithOptions(decimal: false, signed: false);
              break;
            }
            case NUMERAL_SYSTEMS.hexadecimal: {
              validator = VALIDATOR.HEXADECIMAL;
              textInputType = TextInputType.text;
              break;
            }
          }
        }

        tempUnitData[_conversionsOrder[i][j]] = UnitData(
          tempProperty[j],
          property: property.name,
          tec: TextEditingController(),
          validator: validator,
          textInputType: textInputType,
        );
      }
      _unitDataList.add(tempUnitData);
    }
  }

  ///Given a list of translated units of measurement it changes the order
  ///of the units (_conversionsOrder) opening a separate page (ReorderPage)
  changeOrderUnits(List<int> result) async {
    //if there arent't any modifications, do nothing
    if (result != null) {
      List arrayCopy = List.filled(_conversionsOrder[_currentPage].length, null);
      for (int i = 0; i < _conversionsOrder[_currentPage].length; i++) {
        arrayCopy[i] = _conversionsOrder[_currentPage][i];
      }
      for (int i = 0; i < _conversionsOrder[_currentPage].length; i++) {
        _conversionsOrder[_currentPage][i] = result.indexOf(arrayCopy[i]);
      }
      _refreshOrderUnits();
      currentUnitDataList = _unitDataList[_currentPage];
      //_currentOrder = _conversionsOrder[_currentPage];
      notifyListeners();
      _saveOrders();
    }
  }

  ///Saves the order of _conversionsOrder of the _currentPage on memory
  _saveOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> toConvertList = [];
    for (int item in _conversionsOrder[_currentPage]) toConvertList.add(item.toString());
    prefs.setStringList("conversion_$_currentPage", toConvertList);
  }

  //Settings section------------------------------------------------------------------

  ///It reads the settings related to the conversions model from the memory of the device
  ///(if there are options saved)
  _checkSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int val1 = prefs.getInt("significant_figures");
    bool val2 = prefs.getBool("remove_trailing_zeros");

    if (val1 != null || val2 != null) {
      if (val1 != null) _significantFigures = val1;

      if (val2 != null) _removeTrailingZeros = val2;

      _refreshConversionsList();
      notifyListeners();
    }
  }

  ///Returns true if you want to remove the trailing zeros of the conversions
  ///e.g. 1.000000000e20 becomes 1e20
  bool get removeTrailingZeros => _removeTrailingZeros;

  ///Returns the list of possibile significant figures
  List<int> get significantFiguresList => _significantFiguresList;

  ///Returns the current significant figures selection
  int get significantFigures => _significantFigures;

  ///Set the ability of remove unecessary trailing zeros and save to SharedPreferences
  ///e.g. 1.000000000e20 becomes 1e20
  set removeTrailingZeros(bool value) {
    _removeTrailingZeros = value;
    _refreshConversionsList();
    notifyListeners();
    _saveSettingsBool('remove_trailing_zeros', _removeTrailingZeros);
  }

  ///Set the current significant figures selection and save to SharedPreferences
  set significantFigures(int value) {
    _significantFigures = value;
    _refreshConversionsList();
    notifyListeners();
    _saveSettingsInt('significant_figures', _significantFigures);
  }

  ///Saves the key value with SharedPreferences
  _saveSettingsInt(String key, int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
  }

  ///Saves the key value with SharedPreferences
  _saveSettingsBool(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }
}
