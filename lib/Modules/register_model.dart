class RegisterModel {
  late String username;
  late String password;
  late String name;
  late String Lastname;
  late String email;
  late String DOB;
  late String contact;
  late String gender;

  RegisterModel(this.username, this.password, this.email, this.name,
      this.Lastname, this.DOB, this.contact, this.gender);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'Username': username,
    'Password': password,
    'FirstName': name,
    'LastName': Lastname,
    'Email': email,
    'DOB': DOB,
    'ContactNumber': contact,
    'Gender': gender,
  };
}