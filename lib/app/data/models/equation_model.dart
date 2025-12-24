class EquationModel {
  final int a;
  final int b;

  EquationModel({
    required this.a,
    required this.b,
  });
  
  int get result => a ~/ b;
}