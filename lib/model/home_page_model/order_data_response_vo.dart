/// order_date : "2024-05-17 13:00:47"
/// order_id : "o_aBK5Zob8YeV1Ojdz"
/// status : "new"
/// invoice_id : "inv_GiJ5lAh4D8"
/// user : null
/// attempts : 0
/// currency : "INR"
/// amount_before_tax : 4
/// tax : 1
/// total_amount : 5.0
/// token : "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ1cm46bmltYmJsIiwiaWF0IjoxNzE1OTUwODQ3LCJleHAiOjE3MTU5NTIwNDcsInR5cGUiOiJvcmRlciIsInN1Yl9tZXJjaGFudF9pZCI6MTEwMCwib3JkZXJfaWQiOiJvX2FCSzVab2I4WWVWMU9qZHoifQ.mVuf7XyC9K39Ziab4-XIZsoCaYaACxh7gC9qhoRmJO8"
/// token_expiration : "2024-05-17 13:20:47"
/// refresh_token : "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ1cm46bmltYmJsIiwiaWF0IjoxNzE1OTUwODQ3LCJleHAiOjE3MTYwMzcyNDcsInR5cGUiOiJvcmRlci1yZWZyZXNoLXRva2VuIiwic3ViX21lcmNoYW50X2lkIjoxMTAwLCJvcmRlcl9pZCI6Im9fYUJLNVpvYjhZZVYxT2pkeiJ9.NBae6Ia7iwoc_cW5UIq4kHJlISneMs78Z7-0Cx3zQXs"
/// refresh_token_expiration : "2024-05-18 13:00:47"
/// next : [{"action":"payment_modes","url":"/api/v3/payment-modes"},{"action":"update_order","url":"/api/v3/update-order"},{"action":"resolve_user","url":"/api/v3/resolve-user"}]

class OrderDataResponseVo {
  OrderDataResponseVo({
      String? orderDate, 
      String? orderId, 
      String? status, 
      String? invoiceId, 
      dynamic user, 
      num? attempts, 
      String? currency, 
      num? amountBeforeTax, 
      num? tax, 
      num? totalAmount, 
      String? token, 
      String? tokenExpiration, 
      String? refreshToken, 
      String? refreshTokenExpiration, 
      List<Next>? next,}){
    _orderDate = orderDate;
    _orderId = orderId;
    _status = status;
    _invoiceId = invoiceId;
    _user = user;
    _attempts = attempts;
    _currency = currency;
    _amountBeforeTax = amountBeforeTax;
    _tax = tax;
    _totalAmount = totalAmount;
    _token = token;
    _tokenExpiration = tokenExpiration;
    _refreshToken = refreshToken;
    _refreshTokenExpiration = refreshTokenExpiration;
    _next = next;
}

  OrderDataResponseVo.fromJson(dynamic json) {
    _orderDate = json['order_date'];
    _orderId = json['order_id'];
    _status = json['status'];
    _invoiceId = json['invoice_id'];
    _user = json['user'];
    _attempts = json['attempts'];
    _currency = json['currency'];
    _amountBeforeTax = json['amount_before_tax'];
    _tax = json['tax'];
    _totalAmount = json['total_amount'];
    _token = json['token'];
    _tokenExpiration = json['token_expiration'];
    _refreshToken = json['refresh_token'];
    _refreshTokenExpiration = json['refresh_token_expiration'];
    if (json['next'] != null) {
      _next = [];
      json['next'].forEach((v) {
        _next?.add(Next.fromJson(v));
      });
    }
  }
  String? _orderDate;
  String? _orderId;
  String? _status;
  String? _invoiceId;
  dynamic _user;
  num? _attempts;
  String? _currency;
  num? _amountBeforeTax;
  num? _tax;
  num? _totalAmount;
  String? _token;
  String? _tokenExpiration;
  String? _refreshToken;
  String? _refreshTokenExpiration;
  List<Next>? _next;
OrderDataResponseVo copyWith({  String? orderDate,
  String? orderId,
  String? status,
  String? invoiceId,
  dynamic user,
  num? attempts,
  String? currency,
  num? amountBeforeTax,
  num? tax,
  num? totalAmount,
  String? token,
  String? tokenExpiration,
  String? refreshToken,
  String? refreshTokenExpiration,
  List<Next>? next,
}) => OrderDataResponseVo(  orderDate: orderDate ?? _orderDate,
  orderId: orderId ?? _orderId,
  status: status ?? _status,
  invoiceId: invoiceId ?? _invoiceId,
  user: user ?? _user,
  attempts: attempts ?? _attempts,
  currency: currency ?? _currency,
  amountBeforeTax: amountBeforeTax ?? _amountBeforeTax,
  tax: tax ?? _tax,
  totalAmount: totalAmount ?? _totalAmount,
  token: token ?? _token,
  tokenExpiration: tokenExpiration ?? _tokenExpiration,
  refreshToken: refreshToken ?? _refreshToken,
  refreshTokenExpiration: refreshTokenExpiration ?? _refreshTokenExpiration,
  next: next ?? _next,
);
  String? get orderDate => _orderDate;
  String? get orderId => _orderId;
  String? get status => _status;
  String? get invoiceId => _invoiceId;
  dynamic get user => _user;
  num? get attempts => _attempts;
  String? get currency => _currency;
  num? get amountBeforeTax => _amountBeforeTax;
  num? get tax => _tax;
  num? get totalAmount => _totalAmount;
  String? get token => _token;
  String? get tokenExpiration => _tokenExpiration;
  String? get refreshToken => _refreshToken;
  String? get refreshTokenExpiration => _refreshTokenExpiration;
  List<Next>? get next => _next;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['order_date'] = _orderDate;
    map['order_id'] = _orderId;
    map['status'] = _status;
    map['invoice_id'] = _invoiceId;
    map['user'] = _user;
    map['attempts'] = _attempts;
    map['currency'] = _currency;
    map['amount_before_tax'] = _amountBeforeTax;
    map['tax'] = _tax;
    map['total_amount'] = _totalAmount;
    map['token'] = _token;
    map['token_expiration'] = _tokenExpiration;
    map['refresh_token'] = _refreshToken;
    map['refresh_token_expiration'] = _refreshTokenExpiration;
    if (_next != null) {
      map['next'] = _next?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// action : "payment_modes"
/// url : "/api/v3/payment-modes"

class Next {
  Next({
      String? action, 
      String? url,}){
    _action = action;
    _url = url;
}

  Next.fromJson(dynamic json) {
    _action = json['action'];
    _url = json['url'];
  }
  String? _action;
  String? _url;
Next copyWith({  String? action,
  String? url,
}) => Next(  action: action ?? _action,
  url: url ?? _url,
);
  String? get action => _action;
  String? get url => _url;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['action'] = _action;
    map['url'] = _url;
    return map;
  }

}