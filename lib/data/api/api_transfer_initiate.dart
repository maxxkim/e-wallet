class ApiTransferInitiate {
  final String transferHash;
  final String status;
  final Map<String, dynamic> wallet;

  ApiTransferInitiate.fromApi(Map<String, dynamic> map)
      : transferHash = map['transfer_hash'],
        wallet = map['wallet'],
        status = map['status'];
}
