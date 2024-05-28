class ParametersModel {
  final DateTime timestamp;
  final double voltage;
  final double current;
  final double torque;
  final double temperature;
  final double thrust;
  final double power;
  final double rpm;
  final double throttle;

  const ParametersModel({
    required this.timestamp,
    required this.voltage,
    required this.current,
    required this.torque,
    required this.temperature,
    required this.thrust,
    required this.power,
    required this.rpm,
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
          rpm == other.rpm &&
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
      rpm.hashCode ^
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
        ' rpm: $rpm,' +
        ' throttle: $throttle,' +
        '}';
  }

  ParametersModel copyWith({
    DateTime? timestamp,
    double? voltage,
    double? current,
    double? torque,
    double? temperature,
    double? thrust,
    double? power,
    double? rpm,
    double? throttle,
  }) {
    return ParametersModel(
      timestamp: timestamp ?? this.timestamp,
      voltage: voltage ?? this.voltage,
      current: current ?? this.current,
      torque: torque ?? this.torque,
      temperature: temperature ?? this.temperature,
      thrust: thrust ?? this.thrust,
      power: power ?? this.power,
      rpm: rpm ?? this.rpm,
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
      'rpm': this.rpm,
      'throttle': this.throttle,
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
      rpm: map['rpm'] as double,
      throttle: map['throttle'] as double,
    );
  }

//</editor-fold>
}
