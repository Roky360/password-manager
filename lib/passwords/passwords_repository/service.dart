import 'package:flutter/material.dart';
import 'package:password_manager/passwords/encryption_service/encryption_service.dart';
import 'package:password_manager/passwords/passwords_repository/category.dart';
import 'package:password_manager/passwords/passwords_repository/passwords_repository.dart';

class Service {
  String id;
  String name;

  // username / email
  String username;
  String password;
  String additionalInfo;
  String categoryId;
  bool isSensitive;
  bool isFavorite;
  String iconUrl;
  String domain;

  Category? get category => PasswordsRepository().categoryMap[categoryId];

  static final Service _emptyService = Service("", "", "");

  static Service get empty => _emptyService;

  Service(
    this.id,
    this.name,
    this.password, {
    this.categoryId = "",
    this.username = "",
    this.additionalInfo = "",
    this.isSensitive = false,
    this.isFavorite = false,
    this.iconUrl = "",
    this.domain = "",
  });

  Service.fromEncryptedJson(String id, Map<String, Object?> json)
      : this(
          id,
          EncryptionService().decryptData(json['name']! as String),
          EncryptionService().decryptData(json['password']! as String),
          categoryId: EncryptionService().decryptData(json['category']! as String),
          username: EncryptionService().decryptData(json['username'] as String),
          additionalInfo: EncryptionService().decryptData(json['info'] as String),
          isSensitive: json['is_sensitive'] as bool,
          isFavorite: json['is_favorite'] as bool,
          iconUrl: EncryptionService().decryptData(json['icon_url'] as String),
          domain: EncryptionService().decryptData(json['domain'] as String),
        );

  Map<String, dynamic> toEncryptedJson() {
    return {
      'name': EncryptionService().encryptData(name),
      'password': EncryptionService().encryptData(password),
      'username': EncryptionService().encryptData(username),
      'info': EncryptionService().encryptData(additionalInfo),
      'category': EncryptionService().encryptData(categoryId),
      'is_sensitive': isSensitive,
      'is_favorite': isFavorite,
      'icon_url': EncryptionService().encryptData(iconUrl),
      'domain': EncryptionService().encryptData(domain),
    };
  }

  Service copyWith({
    String? id,
    String? name,
    String? username,
    String? password,
    String? additionalInfo,
    String? categoryId,
    bool? isSensitive,
    bool? isFavorite,
    String? iconUrl,
    String? domain,
  }) {
    return Service(
      id ?? this.id,
      name ?? this.name,
      username: username ?? this.username,
      password ?? this.password,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      categoryId: categoryId ?? this.categoryId,
      isSensitive: isSensitive ?? this.isSensitive,
      isFavorite: isFavorite ?? this.isFavorite,
      iconUrl: iconUrl ?? this.iconUrl,
      domain: domain ?? this.domain,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Service && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Widget getIcon({double size = 24, bool filled = false}) {
    Widget defaultIcon() => Icon(
      filled ? Icons.circle : Icons.circle_outlined,
      color: category != null ? category!.color.toMaterialColor() : Colors.blueGrey,
      size: size,
    );

    if (iconUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 3),
        child: Image.network(
          iconUrl,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => defaultIcon(),
        ),
      );
    } else {
      return defaultIcon();
    }
  }

  /// Compares between this [Service] and [other].
  ///
  /// A favorite service will come before a non-favorite one,
  /// then in alphabetical order.
  int compareTo(Service other) {
    final int aFav = isFavorite ? 1 : 0;
    final int bFav = other.isFavorite ? 1 : 0;
    final comp = bFav.compareTo(aFav);
    return comp == 0 ? name.compareTo(other.name) : comp;
  }
}
