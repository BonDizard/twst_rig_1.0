class ParametersModel {
  final DateTime timestamp;
  final double voltage;
  final double current;
  final double torque;
  final double temperature;
  final double thrust;
  final double power;
  final double speed;
  final int pwm;
  final int throttle;

  const ParametersModel({
    required this.timestamp,
    required this.pwm,
    required this.voltage,
    required this.current,
    required this.torque,
    required this.temperature,
    required this.thrust,
    required this.power,
    required this.speed,
    required this.throttle,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParametersModel &&
          runtimeType == other.runtimeType &&
          timestamp == other.timestamp &&
          voltage == other.voltage &&
          current == other.current &&
          torque == other.torque &&
          temperature == other.temperature &&
          thrust == other.thrust &&
          power == other.power &&
          speed == other.speed &&
          throttle == other.throttle);

  @override
  int get hashCode =>
      timestamp.hashCode ^
      voltage.hashCode ^
      current.hashCode ^
      torque.hashCode ^
      temperature.hashCode ^
      thrust.hashCode ^
      power.hashCode ^
      speed.hashCode ^
      throttle.hashCode;

  @override
  String toString() {
    return 'data{' +
        ' timestamp: $timestamp,' +
        ' voltage: $voltage,' +
        ' current: $current,' +
        ' torque: $torque,' +
        ' temperature: $temperature,' +
        ' thrust: $thrust,' +
        ' power: $power,' +
        ' speed: $speed,' +
        ' throttle: $throttle,' +
        ' pwm: $pwm,' +
        '}';
  }

  ParametersModel copyWith({
    DateTime? timestamp,
    double? voltage,
    int? pwm,
    double? current,
    double? torque,
    double? temperature,
    double? thrust,
    double? power,
    double? speed,
    int? throttle,
  }) {
    return ParametersModel(
      pwm: pwm ?? this.pwm,
      timestamp: timestamp ?? this.timestamp,
      voltage: voltage ?? this.voltage,
      current: current ?? this.current,
      torque: torque ?? this.torque,
      temperature: temperature ?? this.temperature,
      thrust: thrust ?? this.thrust,
      power: power ?? this.power,
      speed: speed ?? this.speed,
      throttle: throttle ?? this.throttle,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': this.timestamp,
      'voltage': this.voltage,
      'current': this.current,
      'torque': this.torque,
      'temperature': this.temperature,
      'thrust': this.thrust,
      'power': this.power,
      'speed': this.speed,
      'throttle': this.throttle,
      'pwm': this.pwm,
    };
  }

  factory ParametersModel.fromMap(Map<String, dynamic> map) {
    return ParametersModel(
      timestamp: map['timestamp'] as DateTime,
      voltage: map['voltage'] as double,
      current: map['current'] as double,
      torque: map['torque'] as double,
      temperature: map['temperature'] as double,
      thrust: map['thrust'] as double,
      power: map['power'] as double,
      speed: map['speed'] as double,
      pwm: map['pwm'] as int,
      throttle: map['throttle'] as int,
    );
  }

//</editor-fold>
}
