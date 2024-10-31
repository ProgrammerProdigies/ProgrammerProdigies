class RegisterModel {
  late String firstName;
  late String lastname;
  late String email;
  late String password;
  late String contact;
  late String gender;
  late String semester;
  late String fCMToken;
  late bool visibility;

  RegisterModel(this.firstName, this.lastname, this.email, this.password,
      this.contact, this.gender, this.semester, this.fCMToken, this.visibility);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'firstName': firstName,
        'LastName': lastname,
        'Email': email,
        'Password': password,
        'ContactNumber': contact,
        'Gender': gender,
        'Semester': semester,
        'FCMToken': fCMToken,
        'Visibility': visibility,
      };

  @override
  String toString() {
    return 'RegisterModel{FirstName: $firstName, Lastname: $lastname, email: $email, password: $password, contact: $contact, gender: $gender, Semester: $semester, FCMToken: $fCMToken, Visibility: $visibility}';
  }
}
