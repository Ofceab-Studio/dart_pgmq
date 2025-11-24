enum Operator {
  equal('='),
  different('!='),
  lessThan('<'),
  lessThanOrEqual('<='),
  greaterThan('>'),
  greaterThanOrEqual('>=');

  const Operator(this.sign);
  final String sign;  
}

class Conditional {
  final String field;
  final Operator operator;  
  final dynamic value;

  Conditional({required this.field, required this.operator, required this.value});
}