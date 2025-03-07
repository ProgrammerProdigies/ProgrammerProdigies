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
  late bool theory;
  late bool practical;
  late bool papers;
  late bool demo;
  late String requestFor;

  RegisterModel(
      this.firstName,
      this.lastname,
      this.email,
      this.password,
      this.contact,
      this.gender,
      this.semester,
      this.fCMToken,
      this.visibility,
      this.theory,
      this.practical,
      this.papers,
      this.demo,
      this.requestFor);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'FirstName': firstName,
        'LastName': lastname,
        'Email': email,
        'Password': password,
        'ContactNumber': contact,
        'Gender': gender,
        'Semester': semester,
        'FCMToken': fCMToken,
        'Visibility': visibility,
        'Theory': theory,
        'Practical': practical,
        'Papers': papers,
        'Demo': demo,
        'RequestFor': requestFor
      };

  @override
  String toString() {
    return 'RegisterModel{FirstName: $firstName, Lastname: $lastname, email: $email, password: $password, contact: $contact, gender: $gender, Semester: $semester, FCMToken: $fCMToken, Visibility: $visibility, Theory: $theory, Practical: $practical, Papers: $papers, Demo $demo, RequestFor $requestFor}';
  }
}
