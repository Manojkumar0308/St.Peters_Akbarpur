import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../model/delivery_summary_model.dart';
import '../model/model.dart';

class AdminSmsReport with ChangeNotifier {
  bool isLoading = false;
  List<MapEntry<DateTime, List<SmsMessage>>> sortedGroups = [];
  SmsDeliverySummary? _summary;

  SmsDeliverySummary? get summary => _summary;
  Map<DateTime, List<SmsMessage>> groupedMessages = {};
  Map<String, double> summaryChart = {};
  double? smsDeliveredPercentage;
  double? smsNotDeliveredPercentage;
  double? smssentPercentage;
  List<SmsMessage> smsMessages = [];
  List<SmsMessage> deliveredMessages = [];
  List<SmsMessage> sentMessages = [];
  List<SmsMessage> undeliveredMessages = [];
  Future<void> fetchSmsMessagesReport(String fdate, String tdate) async {
    groupedMessages.clear();
    sortedGroups.clear();
    deliveredMessages.clear();
    sentMessages.clear();
    undeliveredMessages.clear();
    isLoading = true;

    final pref = await SharedPreferences.getInstance();
    // using getString method of sharedPreference to store saved value.

    final schoolId = pref.getInt('schoolid');

    final url =
        'http://app.online-sms.in/api/Delivery/DeliveryReport?fd=$fdate&td=$tdate&schoolid=$schoolId';
    print(url);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      isLoading = false;
      notifyListeners();
      try {
        final decodedData = GZipCodec().decode(response.bodyBytes);
        final data = utf8.decode(decodedData);
        final jsonList = json.decode(data);
        notifyListeners();
        if (jsonList is List) {
          smsMessages =
              jsonList.map((data) => SmsMessage.fromJson(data)).toList();
          notifyListeners();
          if (smsMessages.isNotEmpty) {
            for (var message in smsMessages) {
              if (message.status == 'Delivered') {
                deliveredMessages.add(message);
                print(deliveredMessages.length);
              } else if (message.status == 'SENT') {
                sentMessages.add(message);
                print(sentMessages.length);
              } else if (message.status == 'Undelivered') {
                undeliveredMessages.add(message);
                print(undeliveredMessages.length);
              }
            }
            print('Delivered Messages: $deliveredMessages');
            print('SENT Messages: $sentMessages');
            print('Undelivered Messages: $undeliveredMessages');
          } else {
            print('No SMS messages available');
          }
          if (smsMessages.isNotEmpty) {
            for (var message in smsMessages) {
              if (groupedMessages.containsKey(message.sentDate)) {
                groupedMessages[message.sentDate]!.add(message);
                notifyListeners();
              } else {
                groupedMessages[message.sentDate] = [message];
                notifyListeners();
              }
            }
            notifyListeners();

            sortedGroups = groupedMessages.entries.toList()
              ..sort((a, b) => b.key.compareTo(a.key));
            notifyListeners();
            print('sorted group is :$sortedGroups');
          } else {
            print('No SMS messages available');
          }
        } else {
          print('Response is not a List of SMS messages');
        }
      } catch (e) {
        isLoading = false;
        notifyListeners();
        print('Error decoding JSON: $e');
      }
    } else {
      isLoading = false;
      notifyListeners();
      throw Exception('Failed to load SMS messages');
    }
  }

  Future<void> fetchSmsDeliverySummary(String fdate, String tdate) async {
    summaryChart.clear();
    final pref = await SharedPreferences.getInstance();
    // using getString method of sharedPreference to store saved value.

    final schoolId = pref.getInt('schoolid');
    final response = await http.get(Uri.parse(
        'http://app.online-sms.in/api/Delivery/DeliverySummary?fd=$fdate&td=$tdate&schoolid=$schoolId'));

    if (response.statusCode == 200) {
      try {
        final jsonList = json.decode(response.body);
        _summary = SmsDeliverySummary.fromJson(jsonList);
        if (_summary?.nsmsdelivered != null &&
            _summary?.nsmssent != null &&
            _summary?.nsmsnotdelivered != null) {
          smsDeliveredPercentage = (_summary?.nsmsdelivered?.toDouble() ?? 0) /
              (_summary?.nsmssent?.toDouble() ?? 1) *
              100;
          smsNotDeliveredPercentage =
              (_summary?.nsmsnotdelivered?.toDouble() ?? 0) /
                  (_summary?.nsmssent?.toDouble() ?? 1) *
                  100;
          smssentPercentage = (0 / 0) * 100;
          summaryChart = {
            "Delivered": smsDeliveredPercentage!,
            "UnDelivered": smsNotDeliveredPercentage!
          };
          notifyListeners();
        } else {
          print('piechart data is null');
        }

        notifyListeners();
      } catch (e) {
        print('Error decoding JSON: $e');
      }
    } else {
      print('Failed to load SMS Delivery Summary');
    }
  }
}
