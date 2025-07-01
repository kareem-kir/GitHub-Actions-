// Removed Firebase import

class CategoryModel {
  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final String imageUrl;
  final bool isLocked;
  final String requiredSubscription;
  final int order;
  final bool isActive;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.imageUrl,
    required this.isLocked,
    required this.requiredSubscription,
    required this.order,
    required this.isActive,
    required this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameAr: json['name_ar'] ?? '',
      description: json['description'] ?? '',
      descriptionAr: json['description_ar'] ?? '',
      imageUrl: json['image_url'] ?? '',
      isLocked: json['is_locked'] ?? false,
      requiredSubscription: json['required_subscription'] ?? 'free',
      order: json['order_index'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'description': description,
      'description_ar': descriptionAr,
      'image_url': imageUrl,
      'is_locked': isLocked,
      'required_subscription': requiredSubscription,
      'order_index': order,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  CategoryModel copyWith({
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    String? imageUrl,
    bool? isLocked,
    String? requiredSubscription,
    int? order,
    bool? isActive,
  }) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      imageUrl: imageUrl ?? this.imageUrl,
      isLocked: isLocked ?? this.isLocked,
      requiredSubscription: requiredSubscription ?? this.requiredSubscription,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
