/// token : "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo2NjgsInN1Yl9tZXJjaGFudF9pZCI6MTEwMCwiZXhwIjoxNzE1OTMxNDQ1LCJ0eXBlIjoibWVyY2hhbnQiLCJpYXQiOjE3MTU5MzAyNDUsImlzcyI6InVybjpuaW1iYmwiLCJ0b2tlbl90eXBlIjoidHJhbnNhY3Rpb24ifQ.ZwXdVK9kipbWOsfBgHGZlYKhErxdLxuz8vDmpMrscH0"
/// expires_at : "2024-05-17 07:37:25"

class GenerateTokenVo {
  GenerateTokenVo({
      String? token, 
      String? expiresAt,}){
    _token = token;
    _expiresAt = expiresAt;
}

  GenerateTokenVo.fromJson(dynamic json) {
    _token = json['token'];
    _expiresAt = json['expires_at'];
  }
  String? _token;
  String? _expiresAt;
GenerateTokenVo copyWith({  String? token,
  String? expiresAt,
}) => GenerateTokenVo(  token: token ?? _token,
  expiresAt: expiresAt ?? _expiresAt,
);
  String? get token => _token;
  String? get expiresAt => _expiresAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['token'] = _token;
    map['expires_at'] = _expiresAt;
    return map;
  }

}