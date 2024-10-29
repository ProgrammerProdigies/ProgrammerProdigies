class RegisterModel {
  late String year;

  RegisterModel( this.year);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'Year': year,
  };
}