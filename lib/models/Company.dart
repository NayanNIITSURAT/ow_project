import 'dart:convert';

enum VERIFICATION_STATUS { VERIFIED, PENDING, DECLINED }
enum COMPANY_STATUS { ACTIVE, SUSPENDED, DEACTIVATED }

class BusinessCategory {
  int? id;
  String name;
  BusinessCategory({
    this.id,
    required this.name,
  });

  BusinessCategory copyWith({
    int? id,
    String? name,
  }) {
    return BusinessCategory(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory BusinessCategory.fromMap(Map<String, dynamic> map) {
    return BusinessCategory(
      id: map['id'] != null ? map['id'] : null,
      name: map['name'],
    );
  }

  String toJson() => json.encode(toMap());

  factory BusinessCategory.fromJson(String source) =>
      BusinessCategory.fromMap(json.decode(source));

  @override
  String toString() => 'BusinessCategory(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BusinessCategory && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

class Company {
  int? id;
  String name;
  String? address;
  String? status;
  String? certificate;
  String? publications;
  String verifyStatus;
  String? verifiedAt;
  BusinessCategory? category;
  Company({
    this.id,
    required this.name,
    this.address = '',
    this.status = '',
    this.certificate = '',
    this.publications = '',
    this.verifyStatus = 'PENDING',
    this.verifiedAt,
    this.category,
  });

  Company copyWith({
    int? id,
    String? name,
    String? address,
    String? status,
    String? certificate,
    String? publications,
    String? verifyStatus,
    String? verifiedAt,
    BusinessCategory? category,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      status: status ?? this.status,
      certificate: certificate ?? this.certificate,
      publications: publications ?? this.publications,
      verifyStatus: verifyStatus ?? this.verifyStatus,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'status': status,
      'certificate': certificate,
      'publications': publications,
      'verifyStatus': verifyStatus,
      'verifiedAt': verifiedAt,
      'category': category?.toMap(),
    };
  }

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['id'] != null ? map['id'] : null,
      name: map['name'],
      address: map['address'],
      status: map['status'],
      certificate: map['certificate'],
      publications: map['publications'],
      verifyStatus: map['verify_status'],
      verifiedAt: map['verifiedAt'] != null ? map['verifiedAt'] : null,
      category: map['industry'] != null
          ? BusinessCategory.fromMap(map['industry'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Company.fromJson(String source) =>
      Company.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Company(id: $id, name: $name, address: $address, status: $status, certificate: $certificate, publications: $publications, verifyStatus: $verifyStatus, verifiedAt: $verifiedAt, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Company &&
        other.id == id &&
        other.name == name &&
        other.address == address &&
        other.status == status &&
        other.certificate == certificate &&
        other.publications == publications &&
        other.verifyStatus == verifyStatus &&
        other.verifiedAt == verifiedAt &&
        other.category == category;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        address.hashCode ^
        status.hashCode ^
        certificate.hashCode ^
        publications.hashCode ^
        verifyStatus.hashCode ^
        verifiedAt.hashCode ^
        category.hashCode;
  }
}
